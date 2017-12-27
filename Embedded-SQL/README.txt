#Commands to run the program.
*Please make sure to change your db.properties file. 

db2 -tvf create.clp
db2 connect to cs157a
db2 prep p2.sqc
cc -I./sqllib/include -c p2.c
cc -o p2 p2.o -L./sqllib/lib -ldb2
./p2 db.properties
