Before running these commands, make sure to have all these files in the DB2 server.
- create.clp
- p3.sql
- p3test.sql
- customp3test.sql
- drop.clp

1. Start creating table
2. Connect to the database (only need to do before compile)
3. Compile the stored procedures file p3.sql
** First time compile will run into some errors because the procedures were not created yet so it cannot drop.
4. Run the sample test
db2 -tvf create.clp
db2 connect to cs157a
db2 -td”@“ -f p3.sql
db2 -tvf p3test.sql

If you want to run another test after sample:
1. Reset the table before running Custom Test
2. Run custom test
3. Drop all tables
db2 -tvf create.clp
db2 -tvf customp3test.sql
db2 -tvf drop.clp

Note: I changed the create.clp file to do additional checking.

User defined error codes & meaning:
-444: Invalid inputs' type
-300: Negative inputs for some procedures or out-of-bound values
-200: Wrong PIN
100: Not Found
0: OK
