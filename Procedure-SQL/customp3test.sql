CONNECT to CS157a;
--Normal testing with valid data
-- create customer (6 customers)
CALL P3.CUST_CRT('M1', 'M', 20, 1111, ?,?,?);
CALL P3.CUST_CRT('F2', 'F', 25, 2222, ?,?,?);
CALL P3.CUST_CRT('M3', 'M', 40, 3333, ?,?,?);
CALL P3.CUST_CRT('F4', 'F', 40, 4444, ?,?,?);
CALL P3.CUST_CRT('M5', 'M', 40, 5555, ?,?,?);
CALL P3.CUST_CRT('F6', 'F', 40, 6666, ?,?,?);

-- customer login (3 cases)
CALL P3.CUST_LOGIN(100, 1111, ?,?,?);
CALL P3.CUST_LOGIN(101, 2222, ?,?,?);
CALL P3.CUST_LOGIN(102, 3333, ?,?,?);

-- open account (2 for each of the customer except one, 1 has 3 accounts)
CALL P3.ACCT_OPN(100, 100, 'C',?,?,?);
CALL P3.ACCT_OPN(100, 200, 'S',?,?,?);
CALL P3.ACCT_OPN(100, 300, 'S',?,?,?);
CALL P3.ACCT_OPN(101, 300, 'C',?,?,?);
CALL P3.ACCT_OPN(101, 400, 'S',?,?,?);
CALL P3.ACCT_OPN(102, 500, 'C',?,?,?);
CALL P3.ACCT_OPN(102, 600, 'S',?,?,?);
CALL P3.ACCT_OPN(103, 700, 'C',?,?,?);
CALL P3.ACCT_OPN(103, 800, 'S',?,?,?);
CALL P3.ACCT_OPN(104, 900, 'C',?,?,?);
CALL P3.ACCT_OPN(104, 1000, 'S',?,?,?);
CALL P3.ACCT_OPN(105, 1100, 'C',?,?,?);

-- close account and verify it (2 in total)
CALL P3.ACCT_CLS(1000,?,?);
SELECT NUMBER, BALANCE, STATUS FROM P3.ACCOUNT WHERE NUMBER = 1000;
CALL P3.ACCT_CLS(1001,?,?);
SELECT NUMBER, BALANCE, STATUS FROM P3.ACCOUNT WHERE NUMBER = 1001;

--deposit into account
--Result 0f 1002 should be 400
CALL P3.ACCT_DEP(1002, 100, ?,?);
--Result 0f 1002 should be 500
CALL P3.ACCT_DEP(1002, 100, ?,?);
--Result 0f 1003 should be 500
CALL P3.ACCT_DEP(1003, 200, ?,?);
--Result 0f 1003 should be 700
CALL P3.ACCT_DEP(1003, 200, ?,?);
--Result of 1004 should be 800
CALL P3.ACCT_DEP(1004, 400, ?,?);
SELECT NUMBER, BALANCE FROM p3.account where NUMBER IN(1002, 1003, 1004);

--withdraw some of the accounts
-- Result of 1002 should be 440
CALL P3.ACCT_WTH(1002, 60, ?, ?);
-- Result of 1003 should be 680
CALL P3.ACCT_WTH(1003, 20, ?, ?);
-- Result of 1004 should be 700
CALL P3.ACCT_WTH(1004, 100, ?, ?);

SELECT NUMBER, BALANCE FROM p3.account where NUMBER IN(1002, 1003, 1004);

--transaction(1)
-- Result of 1002 should be 500
-- Result of 1003 should be 620
CALL P3.ACCT_TRX(1003, 1002, 60, ?,?);

--add interest(1)
CALL P3.ADD_INTEREST (0.5, 0.1,?,?);
SELECT NUMBER, BALANCE, TYPE FROM p3.account;


--Error testing for each stored procedure
--invalid create customer (3)
CALL P3.CUST_CRT('M1', 'S', 20, 1111, ?,?,?);
CALL P3.CUST_CRT('F2', '0', 25, 0000, ?,?,?);
CALL P3.CUST_CRT('M3', 'M', -1, 2222, ?,?,?);

--invalid customer log in(3)
CALL P3.CUST_LOGIN(102, 2222, ?, ?, ?);
CALL P3.CUST_LOGIN(999, 9999, ?, ?, ?);
CALL P3.CUST_LOGIN(104, 444, ?, ?, ?);

--invalid account open(3)
CALL P3.ACCT_OPN(102, 600, 'V',?,?,?);
CALL P3.ACCT_OPN(100, -100, 'S',?,?,?);
CALL P3.ACCT_OPN(999, 700, 'S',?,?,?);

--invalid close account (2)
CALL P3.ACCT_CLS(9999,?,?);
CALL P3.ACCT_CLS(1015,?,?);

--invalid deposit (2)
CALL P3.ACCT_DEP(9999, 22, ?,?);
--negative deposit
CALL P3.ACCT_DEP(1004, -22, ?,?);
--deposit into a closed account
CALL P3.ACCT_DEP(1000, -22, ?,?);

--invalid withdraw (3)
--withdraw from closed account
CALL P3.ACCT_WTH(1000, 22, ?, ?);
--over drawn
CALL P3.ACCT_WTH(1002, 2000, ?, ?);
--negative input
CALL P3.ACCT_WTH(1003, -88, ?, ?);

--transfer to another account (3)
--transfer to an invalid account
CALL P3.ACCT_TRX(1003, 9999, 66, ?,?);
--transfer negative value
CALL P3.ACCT_TRX(1003, 1004, -66, ?,?);
--transfer from an invalid account
CALL P3.ACCT_TRX(9999, 1004, 44, ?,?);

--invalid interest (2)
CALL P3.ADD_INTEREST (0.5, -0.1,?,?);
CALL P3.ADD_INTEREST (1.0, 3.0,?,?);
