CREATE TRIGGER UpdateLoanStatusOnPayment
ON LoanPayments
FOR INSERT
AS
BEGIN
    DECLARE @LoanID INT, @PaymentAmount DECIMAL(18,2);
    SELECT @LoanID = LoanID, @PaymentAmount = PaymentAmount FROM INSERTED;

    -- Check if loan is fully paid off
    DECLARE @RemainingLoanAmount DECIMAL(18,2);
    SELECT @RemainingLoanAmount = LoanAmount FROM Loans WHERE LoanID = @LoanID;

    IF @RemainingLoanAmount <= 0
    BEGIN
        UPDATE Loans
        SET Status = 'Paid'
        WHERE LoanID = @LoanID;
    END
END;
********************************************************************************************************************************
CREATE TRIGGER trg_Accounts_Audit    -- Audits all changes to the 'Accounts' table (INSERT, UPDATE, DELETE)
ON Accounts                          -- The changes are recorded in the 'AuditLogs' table
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- For INSERT
    INSERT INTO AuditLogs (TableName, Operation, RecordID, Details)
    SELECT 
        'Accounts',
        'INSERT',
        i.AccountID,
        CONCAT('New Account Created with Balance: ', i.Balance)
    FROM 
        INSERTED i
    WHERE NOT EXISTS (SELECT 1 FROM DELETED d WHERE d.AccountID = i.AccountID);

    -- For DELETE
    INSERT INTO AuditLogs (TableName, Operation, RecordID, Details)
    SELECT 
        'Accounts',
        'DELETE',
        d.AccountID,
        CONCAT('Account Deleted with Balance: ', d.Balance)
    FROM 
        DELETED d
    WHERE NOT EXISTS (SELECT 1 FROM INSERTED i WHERE i.AccountID = d.AccountID);

    -- For UPDATE
    INSERT INTO AuditLogs (TableName, Operation, RecordID, Details)
    SELECT 
        'Accounts',
        'UPDATE',
        i.AccountID,
        CONCAT('Balance changed to ', i.Balance)
    FROM 
        INSERTED i
    INNER JOIN 
        DELETED d ON i.AccountID = d.AccountID
    WHERE 
        i.Balance <> d.Balance; -- Only log if balance changed
END;

*****************************************************************************************************************************************
CREATE VIEW view_CustomerAccounts AS

SELECT 
    C.Name AS CustomerName,
    C.Phone,
    C.Email,
    A.AccountID,
    A.AccountType,
    A.Balance,
    A.DateOpened
FROM 
    Customers C
INNER JOIN 
    Accounts A ON C.CustomerID = A.CustomerID;
*************************************************************************************************************************************************
CREATE VIEW view_TransactionHistory AS
SELECT 
    T.TransactionID,
    T.Date,
    T.TransactionType,
    T.Amount,
    A.AccountID,
    C.Name AS CustomerName,
    E.Name AS EmployeeName
FROM 
    Transactions T
INNER JOIN 
    Accounts A ON T.AccountID = A.AccountID
INNER JOIN 
    Customers C ON A.CustomerID = C.CustomerID
LEFT JOIN 
    Employees E ON T.EmployeeID = E.EmployeeID;
	select * from view_TransactionHistory

****************************************************************************************************************************************************




