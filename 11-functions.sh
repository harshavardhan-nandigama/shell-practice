#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then 
    echo "ERROR:: please run this script with root acess"
    exit 1 #give other than 0 upto 127
else
    echo "you are running with root access"
fi

VALIDATE(){
    if [ $? -eq 0]
    then
        echo "Installing $2 is ...SUCCESS"
    else
        echo "Installing $2 is ... FAILURE"
        exit 1
    fi
}

dnf list instlalled mysql
if [ S$? -ne 0]
then
    echo "MySQL is not installed...going to install it"
    dnf install mysql -y
    VALIDATE $? "MySQL"
else 
 echo "MySQL is already installed ...nothing to do"
 fi

 dnf list installed python3
 if [ $? -ne 0 ]
 then
    echo "pyhton3 is not installed...going to install it"
    dnf install python -y
    VALIDATE $? "python"
else 
    echo "python3 is alredy installed... nothing to do"
fi

dnf list installed nginx
if [ $? -ne 0 ]
then
    echo "nginx is not installed...going to install it"
    dnf install nginx -y
    VALIDATE $? "nginx"
else 
    echo "nginx is already instlled...Nothing ot do"
fi