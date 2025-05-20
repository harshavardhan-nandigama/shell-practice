#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-log"
SCRIPT_NAME="$LOGS_FOLDER/$SCRIPT_NAME.log"
LOG_FILE="LOGS_FOLDER/$SCRIPT_NAME.log"
PACKAGES=("mysql" "python" "nginx" "httpd")

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

#for packages in ${PACKAGES[@]}
for package in $@
do
    dnf list instlalled $package 
    if [ $? -ne 0 ]
    then
        echo "$package is not installed...going to install it" | tee -a&>>LOG_FILE
        dnf install $package -y
        VALIDATE $? "$package"
    else 
        echo -e "$package is already installed...$Y nothing to do $N" | tee -a&>>LOG_FILE
    fi
done

 