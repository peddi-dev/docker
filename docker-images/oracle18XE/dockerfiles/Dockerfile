##
#  First we select our base image that we will use to build from.
#  in this case we will use Oracle Linux 7.6 
#
FROM oraclelinux:7.6

##
#  Then we provide some basic information - you can customise this to your need, but 
#  I just add my email here 
#
MAINTAINER peddi.groups@gmail.com

##
#  We are now switching to the root user as the next steps will require root permission
#
USER root

##
#  First we add the “oracle”  Unix user and groups and assign a password to the user
#  note - you will have to make this password more complex in production configurations
#
RUN groupadd -g 501 oinstall \
  && groupadd -g 502 dba \
  && groupadd -g 503 oper \
  && useradd -m -g oinstall -G oinstall,dba,oper -u 501 oracle \
  && echo 'oracle:Kiwi123' | chpasswd

## 
#  now as Pre-requisite for the Oracle 18c XE Install
#  a few extra packages are required - and as I use tools like tree, which and sysstat
#  we add them here as well.  You can customise this, but “file” and “openssl” must be installed
#  before you can install Oracle 18c XE.
#  We also want to keep the image small, so to do this we cleanup after the install and remove
#  all temporary files and install caches using during installation
#
 RUN rpm --rebuilddb \
 && yum -y install file openssl lsof sudo sysstat tree wget which  \
 && yum clean all \
 && rm -rf /var/cache/yum/*

## 
#  Update sudoers to allow the Oracle Unix user to run commands as the root user.  
#  In this example I keep it simple and allow the user to execute any command without a password
#  but for production configurations you might want to look at locking this down more.
#  We also create a few directories and make sure the Oracle Unix user own them.
#  First the directory /opt/oracle in which Oracle 18c XE will be installed into
#  Second we create the /install folder which will be a temporary location from where we will install files
#  Third we create a bin directory in the Oracle user home folder location - where we can place scripts
#
RUN echo "oracle ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Defaults !requiretty"  >> /etc/sudoers \
  && mkdir -p /opt/oracle \
  && mkdir -p /install \
  && mkdir -p /home/oracle/bin \
  && chown -R oracle:oinstall /opt/oracle \
  && chown -R oracle:oinstall /home/oracle/bin

## 
#  Next, we copy the Oracle 18c XE software to the install directory followed by 
#  setting the ORACLE_DOCKER_INSTALL=true environment variable before we install
#  the Oracle 18c XE software with “yum -y localinstall” command.  
#  The ORACLE_DOCKER_INSTALL variable is used to indicate we are installing into Docker
#  and as part of the pre/post install scripts Oracle will use this to remove/unset settings
#  which is not required when using Docker
#  on the last part we clean up the install folder and any temporary files
#
COPY software/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm /install
COPY software/oracle-database-xe-18c-1.0-1.x86_64.rpm /install/
ENV ORACLE_DOCKER_INSTALL=true
RUN cd /install \
 && yum -y localinstall oracle-database-*18c*  \
 && yum clean all \
 && rm -rf /var/cache/yum/* \
&& rm -rf /install/oracle*.rpm

## 
#  Next we specify which ports we want to expose for Oracle when a container 
#  is created from this image.  We pick the defaults for the listener and EM Express
#
EXPOSE 1521 5500

## 
#  Now in this example, we will use the default configure option and during my 
#  testing I found that for Docker I had to remove memlock options from 
#  the /etc/security/limits.d/oracle-database-preinstall-18c.conf file
#
#  Creating the XE database: 
#   - Now this is done by running the "/etc/init.d/oracle-xe-18c configure” command
#     but this command expects input for user passwords, now two are required and 
#     the second is just confirmation of the first.  This password is for the 
#     SYS, SYSTEM and PDBADMIN users - they will all use the same one. 
#     printf is useful here to “pass” the password into the configure command so that
#     no user interaction is required.  
#     
#
RUN sed -i -e "s/^.*memlock.*//g" /etc/security/limits.d/oracle-database-preinstall-18c.conf \
 && printf Kiwi123\\nKiwi123\\n  | /etc/init.d/oracle-xe-18c configure

## 
#  We now add an entrypoint script.  There is a lot of information on Entrypoint 
#  and CMD options in the docker documentation for more reference.  But in this example
#  We will copy a script called “manage-xe.sh” to the /home/oracle/bin folder which is
#  executable by the Oracle Unix account and this will be used to start the Oracle 18c XE
#  database on launch of the container
#
COPY scripts/manage-xe.sh /home/oracle/bin
RUN chown oracle:oinstall /home/oracle/bin/manage-xe.sh \
  && chmod 775 /home/oracle/bin/manage-xe.sh

##
#  We now switch to the “oracle” user as up to this point all operations were performed as 
#  the root user.  We also specify the work directory - which in this case is the default
#  oracle user home folder location
#
USER oracle
WORKDIR /home/oracle

## 
#  Something really useful is to set current environment for the oracle user.
#  This is done using the ENV command. With this we specify the core parameters that will 
#  make things simpler for  the “oracle” unix account, example setting the PATH, ORACLE_HOME
#  ORACLE_SID etc.
#
ENV ORACLE_DOCKER_INSTALL=true \
    ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE \
    PATH=/home/oracle/bin:/opt/oracle/product/18c/dbhomeXE/bin:$PATH \
    NLS_DATE_FORMAT="dd/mm/yyyy:hh24:mi:ss" \
    ORACLE_SID=XE

## 
#  We clear bash history to keep things clean - this is optional
#
RUN history -c

## 
#  The last instruction is to specify what will be executed when the container is created 
#  from the image.  There are a few options, you could just start a bash shell and then 
#  manually start the Oracle 18c XE database, or, you could call the custom manage-xe.sh
#  script with the “start” parameter to start the listener and XE database on container 
#  creation (run time)
#
# CMD ["/bin/bash”]
#
CMD ["/home/oracle/bin/manage-xe.sh", "-o", "start"]

