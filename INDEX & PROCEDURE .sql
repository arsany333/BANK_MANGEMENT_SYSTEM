CREATE INDEX IDX_CustomerID ON Accounts(CustomerID);

CREATE INDEX IDX_AccountID ON Transactions(AccountID);

create  nonclustered index IDX_balance on accounts (balance);
***************************************************************************************************
CREATE PROCEDURE CreateCustomer   -- Adds a new customer record to the Customers table
@Name NVARCHAR(100), @Address NVARCHAR(255), @Phone NVARCHAR(20), 
@Email NVARCHAR(100), @DateOfBirth DATE
AS
BEGIN
    INSERT INTO Customers (Name, Address, Phone, Email, DateOfBirth)
    VALUES (@Name, @Address, @Phone, @Email, @DateOfBirth);
END;
****************************************************************************************************
ALTER PROCEDURE CreateCustomer
    @Name NVARCHAR(100), 
    @Address NVARCHAR(255), 
    @Phone NVARCHAR(20), 
    @Email NVARCHAR(100), 
    @DateOfBirth DATE
AS
BEGIN
    -- Check if the customer is at least 18 years old
    IF DATEDIFF(YEAR, @DateOfBirth, GETDATE()) < 18
    BEGIN
        RAISERROR('Cannot open an account for a person under 18 years old.', 16, 1);
        RETURN;
    END

    -- Proceed with insertion if age is valid
    INSERT INTO Customers (Name, Address, Phone, Email, DateOfBirth)
    VALUES (@Name, @Address, @Phone, @Email, @DateOfBirth);
END;
************************************************************************************************************
CREATE PROCEDURE createemployee  -- ADD A NEW EMPLOYEE
@NAME NVARCHAR(100),@POSITION NVARCHAR(50),@BRANCHID INT 
AS 
BEGIN 
   INSERT INTO EMPLOYEES(NAME,POSITION,BRANCHID)
   VALUES(@NAME ,@POSITION,@BRANCHID)
END;
****************************************************************************************************
CREATE PROCEDURE CreateBranch      -- ADD A BRANCH 
    @BranchName NVARCHAR(100),
    @BranchAddress NVARCHAR(255)
AS
BEGIN
    INSERT INTO Branches (BranchName, BranchAddress)
    VALUES (@BranchName, @BranchAddress);
END;
*****************************************************************************************************
CREATE PROCEDURE OpenAccount
CREATE PROCEDURE OpenAccount      --Opens a new account for an existing customer
    @CustomerID INT,
    @AccountType NVARCHAR(50),
    @Balance DECIMAL(18,2)
AS
BEGIN
    INSERT INTO Accounts (CustomerID, AccountType, Balance)
    VALUES (@CustomerID, @AccountType, @Balance);
END;**
******************************************************************************************************
CREATE PROCEDURE ProcessTransaction     --Processes deposit or withdrawal transactions for an account
    @AccountID INT,
    @EmployeeID INT,
    @TransactionType NVARCHAR(50),
    @Amount DECIMAL(18,2)
AS
BEGIN
    IF @TransactionType = 'Deposit'
    BEGIN
        UPDATE Accounts
        SET Balance = Balance + @Amount
        WHERE AccountID = @AccountID;
    END
    ELSE IF @TransactionType = 'Withdrawal'
    BEGIN
        -- Ensure balance doesn't go below 0 unless it's a Credit account
        IF EXISTS (SELECT 1 FROM Accounts WHERE AccountID = @AccountID AND Balance >= @Amount)
        BEGIN
            UPDATE Accounts
            SET Balance = Balance - @Amount
            WHERE AccountID = @AccountID;
        END
        ELSE
        BEGIN
            RAISERROR('Insufficient balance for withdrawal', 16, 1);
        END
    END
    INSERT INTO Transactions (AccountID, EmployeeID, TransactionType, Amount)
    VALUES (@AccountID, @EmployeeID, @TransactionType, @Amount);
END;

***********************************************************************************************************
CREATE PROCEDURE ApplyLoan   --Applies for a loan for a specific customer with given interest and amount
    @CustomerID INT,
    @EmployeeID INT,
    @LoanAmount DECIMAL(18,2),
    @InterestRate DECIMAL(5,2)
AS
BEGIN
    INSERT INTO Loans (CustomerID, EmployeeID, LoanAmount, InterestRate, Status)
    VALUES (@CustomerID, @EmployeeID, @LoanAmount, @InterestRate, 'Pending');
END;
************************************************************************************************************
CREATE PROCEDURE MakeLoanPayment   --Reduces loan amount by the payment and records it in LoanPayments
    @LoanID INT,
    @PaymentAmount DECIMAL(18,2)
AS
BEGIN
    UPDATE Loans
    SET LoanAmount = LoanAmount - @PaymentAmount
    WHERE LoanID = @LoanID;

    INSERT INTO LoanPayments (LoanID, PaymentAmount)
    VALUES (@LoanID, @PaymentAmount);
END;
**************************************************************************************************************
CREATE PROCEDURE TransferFunds    -- Transfers funds between two accounts if source has enough balance.
                                  -- Records the transaction for both accounts.
    @SourceAccountID INT,
    @DestinationAccountID INT,
    @EmployeeID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    -- Ensure balance is sufficient
    IF EXISTS (SELECT 1 FROM Accounts WHERE AccountID = @SourceAccountID AND Balance >= @Amount)
    BEGIN
        -- Deduct from source account
        UPDATE Accounts SET Balance = Balance - @Amount WHERE AccountID = @SourceAccountID;
        -- Add to destination account
        UPDATE Accounts SET Balance = Balance + @Amount WHERE AccountID = @DestinationAccountID;
        
        -- Record the transaction
        INSERT INTO Transactions (AccountID, EmployeeID, TransactionType, Amount)
        VALUES (@SourceAccountID, @EmployeeID, 'Transfer', @Amount);
        INSERT INTO Transactions (AccountID, EmployeeID, TransactionType, Amount)
        VALUES (@DestinationAccountID, @EmployeeID, 'Transfer', @Amount);
    END
    ELSE
    BEGIN
        RAISERROR('Insufficient balance for transfer', 16, 1);
        ROLLBACK;
    END
END;
********************************************************************************************************************
--  Safely transfers a specified amount of money from one account to another.
--  Uses a transaction to ensure atomicity (either all operations succeed or none do )
--  includes error handling for rollback on failure.


ALTER PROCEDURE TransferFunds      
    @SourceAccountID INT,
    @DestinationAccountID INT,
    @EmployeeID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Ensure balance is sufficient
        IF EXISTS (SELECT 1 FROM Accounts WHERE AccountID = @SourceAccountID AND Balance >= @Amount)
        BEGIN
            -- Deduct from source account
            UPDATE Accounts 
            SET Balance = Balance - @Amount 
            WHERE AccountID = @SourceAccountID;

            -- Add to destination account
            UPDATE Accounts 
            SET Balance = Balance + @Amount 
            WHERE AccountID = @DestinationAccountID;

            -- Record the transaction for source (outgoing money - negative amount)
            INSERT INTO Transactions (AccountID, EmployeeID, TransactionType, Amount)
            VALUES (@SourceAccountID, @EmployeeID, 'Transfer', -@Amount);

            -- Record the transaction for destination (incoming money - positive amount)
            INSERT INTO Transactions (AccountID, EmployeeID, TransactionType, Amount)
            VALUES (@DestinationAccountID, @EmployeeID, 'Transfer', @Amount);

            COMMIT; -- If everything successful
        END
        ELSE
        BEGIN
            RAISERROR('Insufficient balance for transfer', 16, 1);
            ROLLBACK;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW; -- Re-throw the error
    END CATCH
END;
