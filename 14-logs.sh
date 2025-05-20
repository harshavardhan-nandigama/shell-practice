#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-log"
SCRIPT_NAME="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" | tee -a&>>LOG_FILE

if [ $USERID -ne 0 ]
then 
    echo -e "$R ERROR:: please run this script with root acess $N" | tee -a&>>LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "you are running with root access" | tee -a&>>LOG_FILE
fi

# validate function takes input as exit status, what command they tried to install 
VALIDATE(){
    if [ $? -eq 0]
    then
        echo "Installing $2 is ...$G SUCCESS $N" | tee -a&>>LOG_FILE
    else
        echo "Installing $2 is ... $R FAILURE $N" | tee -a&>>LOG_FILE
        exit 1
    fi
}

dnf list instlalled mysql
if [ $? -ne 0 ]
then
    echo "MySQL is not installed...going to install it" | tee -a&>>LOG_FILE
    dnf install mysql -y
    VALIDATE $? "MySQL"
else 
 echo -e "MySQL is already installed...$Y nothing to do $N" | tee -a&>>LOG_FILE

 dnf list installed python3
 if [ $? -ne 0 ]
 then
    echo "pyhton3 is not installed...going to install it" | tee -a&>>LOG_FILE
    dnf install python -y
    VALIDATE $? "python"
else 
    echo -e "python3 is alredy installed... $Y nothing to do $N" | tee -a&>>LOG_FILE
fi

dnf list installed nginx
if [ $? -ne 0 ]
then
    echo "nginx is not installed...going to install it" | tee -a&>>LOG_FILE
    dnf install nginx -y
    VALIDATE $? "nginx"
else 
    echo -e "nginx is already instlled...$Y Nothing ot do $N"| tee -a&>>LOG_FILE
fi