CREATE DATABASE  banking_management_system
GO 

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    DateOfBirth DATE
);


CREATE TABLE Branches (
    BranchID INT PRIMARY KEY IDENTITY(1,1),
    BranchName NVARCHAR(100) NOT NULL,
    BranchAddress NVARCHAR(255)
);


CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Position NVARCHAR(50),
    BranchID INT,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);


CREATE TABLE Accounts (
	AccountID INT PRIMARY KEY ,
    CustomerID INT NOT NULL,
    AccountType NVARCHAR(50) NOT NULL CHECK (AccountType IN ('Savings', 'Checking', 'Credit')),
    Balance DECIMAL(18,2) DEFAULT 0,
    DateOpened DATE DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT NOT NULL,
    EmployeeID INT, -- Who handled the transaction
   TransactionType NVARCHAR(50) NOT NULL CHECK (TransactionType IN ('Deposit', 'Withdrawal', 'Transfer')),
    Amount DECIMAL(18,2) NOT NULL,
    Date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);


CREATE TABLE Loans (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    EmployeeID INT, -- Who processed the loan
    LoanAmount DECIMAL(18,2) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL, -- Example: 7.50
    StartDate DATE DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected'
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);


CREATE TABLE LoanPayments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    LoanID INT NOT NULL,
    PaymentDate DATE DEFAULT GETDATE(),
    PaymentAmount DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

-- Create a table to store audit logs for tracking data changes in other tables
CREATE TABLE AuditLogs (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(100),
    Operation NVARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    RecordID INT,           -- The ID of the record that changed
    ChangedBy NVARCHAR(100) DEFAULT SYSTEM_USER,   -- Who made the change
    ChangeDate DATETIME DEFAULT GETDATE(),          -- When the change happened
    Details NVARCHAR(MAX)      
);



ALTER TABLE Accounts ADD CONSTRAINT CHK_AccountBalance CHECK (Balance >= 0 OR AccountType = 'Credit');
ALTER TABLE Customers ADD CONSTRAINT UQ_Email UNIQUE (Email);
ALTER TABLE Customers ADD CONSTRAINT UQ_Phone UNIQUE (Phone);