--1.  CUST_CRT (Name, Gender, Age, Pin, ID, sqlcode, err_msg)
--2.  CUST_LOGIN (ID, Pin, Valid, sqlcode, err_msg)  (Valid = 1 if match, 0 for failure)
--3.  ACCT_OPN (ID, Balance, Type, Number, sqlcode, err_msg)
--4.  ACCT_CLS (Number, sqlcode, err_msg)
--5.  ACCT_DEP (Number, Amt, sqlcode, err_msg)
--6.  ACCT_WTH (Number, Amt, sqlcode, err_msg)
--7.  ACCT_TRX (Src_Acct, Dest_Acct, Amt, sqlcode, err_msg)
--8.  ADD_INTEREST (Savings_Rate, Checking_Rate, sqlcode, err_msg)
--
drop procedure p3.CUST_CRT@
drop procedure p3.CUST_LOGIN@
drop procedure p3.ACCT_OPN@
drop procedure p3.ACCT_CLS@
drop procedure p3.ACCT_DEP@
drop procedure p3.ACCT_WTH@
drop procedure p3.ACCT_TRX@
drop procedure p3.ADD_INTEREST@
--
--
CREATE PROCEDURE p3.CUST_CRT
(IN Name CHAR(15), IN Gender CHAR, IN Age INTEGER, IN Pin INTEGER, OUT id INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(30))
LANGUAGE SQL
BEGIN
  DECLARE SQLCODE INTEGER DEFAULT 0;

  DECLARE P1 CURSOR FOR
    SELECT ID FROM FINAL TABLE(INSERT INTO P3.CUSTOMER(NAME, GENDER, AGE, PIN) VALUES (Name,Gender,Age,P3.ENCRYPT(Pin)));

  DECLARE EXIT HANDLER FOR NOT FOUND, SQLEXCEPTION
    BEGIN
      SET sql_code = -444;
      SET err_msg = 'Invalid inputs';
    END;

  OPEN P1;
  FETCH P1 INTO ID;
  CLOSE P1;
  SET sql_code = 0;
END @

CREATE PROCEDURE p3.CUST_LOGIN
(IN idInput INTEGER, IN PinInput INTEGER, OUT valid INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(30))
LANGUAGE SQL
BEGIN
  DECLARE tempPIN INTEGER;
  DECLARE SQLCODE INTEGER DEFAULT 0;
  DECLARE v1 CURSOR FOR SELECT PIN FROM P3.CUSTOMER WHERE ID = idInput;

  DECLARE EXIT HANDLER FOR NOT FOUND, SQLEXCEPTION
    BEGIN
      SET sql_code = SQLCODE;
      IF (sql_code = 100) THEN BEGIN SET err_msg = 'Not Found Account'; SET valid = 0; END;
      ELSEIF (sql_code < 0) THEN BEGIN SET sql_code = -444 ;SET err_msg = 'Invalid ID input'; SET valid = 0; END;
      END IF;
    END;

  open v1;
  fetch v1 into tempPIN;
  close v1;

  IF (P3.DECRYPT(tempPIN) = PinInput)
  THEN
    SET valid = 1;
    SET sql_code = 0;
  ELSE
    SET valid = 0;
    SET sql_code = -200;
    SET err_msg = 'Wrong PIN';
  END IF;

END@
--3.  ACCT_OPN (ID, Balance, Type, Number, sqlcode, err_msg)
CREATE PROCEDURE p3.ACCT_OPN
(IN idInput INTEGER, IN balanceInput INTEGER, IN typeInput CHAR, OUT account_num Integer, OUT sql_code INTEGER, OUT err_msg VARCHAR(30))
LANGUAGE SQL
BEGIN
  DECLARE SQLCODE INTEGER DEFAULT 0;
  DECLARE op CURSOR FOR SELECT NUMBER FROM FINAL TABLE(INSERT INTO P3.ACCOUNT(ID, BALANCE, TYPE, STATUS) VALUES (idInput, balanceInput, typeInput, 'A'));
  DECLARE CONTINUE HANDLER FOR NOT FOUND, SQLEXCEPTION
    BEGIN
      SET sql_code = SQLCODE;
      IF (sql_code = 100) THEN SET err_msg = 'Not Found Account'; RETURN;
      ELSEIF (sql_code < 0) THEN SET sql_code = -444; SET err_msg = 'Invalid inputs';RETURN;
      END IF;
    END;
  IF (balanceInput < 0) THEN BEGIN SET sql_code = -300; SET err_msg = 'Deposit Amount < 0'; RETURN; END; END IF;
  OPEN op;
  FETCH op INTO account_num;
  CLOSE op;
  IF(account_num >= 1000) THEN SET sql_code = 0; END IF;
END@

--4.  ACCT_CLS (Number, sqlcode, err_msg)
CREATE PROCEDURE p3.ACCT_CLS
(IN numberInput INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(30))
LANGUAGE SQL
BEGIN
  DECLARE SQLCODE INTEGER DEFAULT 0;
  DECLARE EXIT HANDLER FOR NOT FOUND, SQLEXCEPTION
    BEGIN
      SET sql_code = SQLCODE;
      IF (sql_code = 100) THEN SET err_msg = 'Not Found Account';
      ELSEIF (sql_code < 0) THEN SET sql_code = -444; SET err_msg = 'Invalid inputs';
      END IF;
    END;

  UPDATE P3.ACCOUNT SET STATUS = 'I', BALANCE = 0 WHERE NUMBER = numberInput;
  SET sql_code = 0;
END@
--5.  ACCT_DEP (Number, Amt, sqlcode, err_msg)
CREATE PROCEDURE p3.ACCT_DEP
(IN numberInput INTEGER, IN amountInput INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(30))
LANGUAGE SQL
BEGIN
  DECLARE SQLCODE INTEGER DEFAULT 0;
  DECLARE EXIT HANDLER FOR NOT FOUND, SQLEXCEPTION
    BEGIN
      SET sql_code = SQLCODE;
      IF (sql_code = 100) THEN SET err_msg = 'Not Found | Closed Account';
      ELSEIF (sql_code < 0) THEN SET sql_code = -444; SET err_msg = 'Invalid inputs';
      END IF;
    END;
  IF (amountInput < 0) THEN BEGIN SET sql_code = -300; SET err_msg = 'Deposit Amount < 0'; END;
  ELSE UPDATE P3.ACCOUNT SET BALANCE = BALANCE + amountInput WHERE NUMBER = numberInput AND STATUS = 'A'; SET sql_code = 0; END IF;
END@
--6.  ACCT_WTH (Number, Amt, sqlcode, err_msg)
CREATE PROCEDURE p3.ACCT_WTH
(IN numberInput INTEGER, IN amountInput INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(30))
LANGUAGE SQL
BEGIN
  DECLARE SQLCODE INTEGER DEFAULT 0;
  DECLARE tempBalance INTEGER;
  DECLARE w1 CURSOR FOR SELECT BALANCE FROM P3.ACCOUNT WHERE NUMBER = numberInput AND STATUS = 'A';

  DECLARE CONTINUE HANDLER FOR NOT FOUND, SQLEXCEPTION
    BEGIN
      SET sql_code = SQLCODE;
      IF (sql_code = 100) THEN SET err_msg = 'Not Found | Closed Account'; RETURN;
      ELSEIF (sql_code < 0) THEN SET sql_code = -444; SET err_msg = 'Invalid inputs'; RETURN;
      END IF;
    END;
  open w1;
  fetch w1 into tempBalance;
  close w1;
  IF (amountInput < 0) THEN BEGIN SET sql_code = -300; SET err_msg = 'Withdraw Amount < 0'; RETURN; END;
  ELSEIF (amountInput > tempBalance) THEN BEGIN SET sql_code = -300; SET err_msg = 'Balance < Withdraw Amount'; RETURN; END;
  END IF;
  UPDATE P3.ACCOUNT SET BALANCE = BALANCE - amountInput WHERE NUMBER = numberInput;
  SET sql_code = 0;
END@

--7.  ACCT_TRX (Src_Acct, Dest_Acct, Amt, sqlcode, err_msg)
CREATE PROCEDURE p3.ACCT_TRX
(IN src_acct INTEGER, IN dest_acct INTEGER, IN amountInput INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(30))
LANGUAGE SQL
BEGIN
  DECLARE SQLCODE INTEGER DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR NOT FOUND, SQLEXCEPTION
    BEGIN
      SET sql_code = SQLCODE;
      IF (sql_code = 100) THEN SET err_msg = 'Not Found Account'; RETURN;
      ELSEIF (sql_code < 0) THEN SET sql_code = -444; SET err_msg = 'Invalid inputs'; RETURN;
      END IF;
    END;
  IF (amountInput < 0) THEN BEGIN SET sql_code = -300; SET err_msg = 'Transfer Amount < 0'; RETURN; END; END IF;
  CALL p3.ACCT_WTH(src_acct, amountInput,sql_code,err_msg);
  IF (sql_code != 0) THEN RETURN;
  ELSE
        CALL p3.ACCT_DEP(dest_acct, amountInput,sql_code,err_msg);
        IF (sql_code != 0) THEN RETURN; END IF;
  END IF;
END@

--8.  ADD_INTEREST (Savings_Rate, Checking_Rate, sqlcode, err_msg)
CREATE PROCEDURE p3.ADD_INTEREST
(IN saving_rate FLOAT, IN checking_rate FLOAT, OUT sql_code INTEGER, OUT err_msg VARCHAR(30))
LANGUAGE SQL
BEGIN
  DECLARE SQLCODE INTEGER DEFAULT 0;
  DECLARE EXIT HANDLER FOR NOT FOUND, SQLEXCEPTION
    BEGIN
      SET sql_code = SQLCODE;
      IF (sql_code < 0) THEN SET sql_code = -444; SET err_msg = 'Invalid inputs';
      END IF;
    END;
  IF(saving_rate < 0 OR saving_rate > 1) THEN BEGIN SET sql_code = -300; SET err_msg = 'Saving Rate > 0 or < 1'; RETURN; END;
  ELSEIF (checking_rate < 0 OR checking_rate > 1) THEN BEGIN SET sql_code = -300; SET err_msg = 'Checking Rate > 0 or < 1'; RETURN; END;
  ELSE SET sql_code = 0; END IF;
  UPDATE P3.ACCOUNT SET BALANCE = BALANCE + (BALANCE * saving_rate) WHERE TYPE = 'S';
  UPDATE P3.ACCOUNT SET BALANCE = BALANCE + (BALANCE * checking_rate) WHERE TYPE = 'C';

END@
