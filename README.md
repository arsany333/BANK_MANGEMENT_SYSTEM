# 🏦 Bank Management System

This project is a **Bank Management System** built using Microsoft SQL Server. It demonstrates the structure, operations, and management processes of a basic banking application, including customer management, account handling, employee operations, transactions, loans, and audit logging.

---

## 📌 Features

- Customer Registration and Unique Identification
- Account Creation and Balance Management
- Transaction Processing (Deposit, Withdrawal, Transfer)
- Employee and Branch Management
- Loan Applications and Payment Tracking
- Automated Loan Status Update via Triggers
- Audit Logging for Account Changes
- Indexed Queries for Performance Optimization
- Database Views for Reporting

---

## 🗃️ Database Schema

### Tables:
- **Customers**
- **Branches**
- **Employees**
- **Accounts**
- **Transactions**
- **Loans**
- **LoanPayments**
- **AuditLogs**



## 🛠️ Stored Procedures

- `CreateCustomer`
- `CreateEmployee`
- `CreateBranch`
- `OpenAccount`
- `ProcessTransaction`
- `ApplyLoan`
- `MakeLoanPayment`
- `TransferFunds`

---

## 🔍 Views

- `view_CustomerAccounts` – displays joined data between customers and their accounts
- `view_TransactionHistory` – complete transactional history with customer and employee data

---

## 🔐 Triggers

- `trg_Accounts_Audit` – tracks INSERT, UPDATE, DELETE changes in Accounts
- `UpdateLoanStatusOnPayment` – updates loan status to "Paid" if fully paid off

---

## ⚡ Indexes

- `IDX_CustomerID` on `Accounts`
- `IDX_AccountID` on `Transactions`
- `IDX_balance` on `Accounts` for performance in balance queries

---



## 🧰 Technologies Used

- SQL Server
- T-SQL (Procedures, Triggers, Views)
- SQL Server Management Studio (SSMS)

---





