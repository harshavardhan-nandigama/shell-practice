#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then 
    echo "ERROR:: please run this script with root access"
else 
    echo "you are running with root access"
fi 

dnf install mysql -y
