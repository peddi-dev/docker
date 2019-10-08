
Step 1:
------
Down load the oracle database preinstall and install package files
oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
oracle-database-xe-18c-1.0-1.x86_64.rpm 

Download oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm

Download oracle-database-xe-18c-1.0-1.x86_64.rpm  from the following link
https://www.oracle.com/database/technologies/xe-downloads.htmli


Step 2:
------- 
Copy the downloaded oracle databaase files into the "software" directory


Step 3: 
-------
get into the root directory where docker files available 
Build the docker image for oracle XE using the following command run the following command
 
 $ sh docker_image_build.sh > docker_image_build.log

Check if there are any errors in the docker_image_build.log

Check if oracle XE db docker image is created with the following command
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
oracle-db           18cXE               a226619755b8        11 days ago         12.9GB


Step 4: 
-------
Create the docker container for oracle XE from the docker image creatd above using the script createOracleXEDockerContainer.sh

 $ sh createOracleXEDockerContainer.sh

 Check if the continer is created with name devXE  
 $ docker container ls -a 

 alternative command to list containers
 $ docker ps -a

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                            NAMES
828200c56546        oracle-db:18cXE     "/home/oracle/bin/ma…"   11 days ago         Up 27 minutes       0.0.0.0:1521->1521/tcp, 0.0.0.0:5500->5500/tcp   devXE



Step 5: 
-------
Connect to the docker container 
$ docker exec -it  <container>  sh

Connect to the Database

$ sqlplus /nolog
SQL*Plus: Release 18.0.0.0.0 - Production on Tue Oct 8 15:19:42 2019
Version 18.4.0.0.0

Copyright (c) 1982, 2018, Oracle.  All rights reserved.


SQL> connect system/Kiwi123@localhost/XE
Connected.



Step 6:
-------

Connect to the database using SQL Developer

system/Kiwi123@localhost:1521/xe as sysdba



