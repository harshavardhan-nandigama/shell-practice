#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then 
    echo "ERROR:: please run this script with root access"
else 
    echo "you are running with root access"
fi 

dnf install mysql -y

#check already installed or not. if installed $? is 0, then 
#If not installed $? is not 0. express is true

if [ $? -ne 0 ]
then 
    echo "MSQL is not installed.. going to install it"
    dnf install mysql -y
    if [ $? -eq 0 ]
    then
        echo "installing MYSQL is..... SUCESS"
    else
        echo "Installing MYSQL is.......FAILURE"
        exit 1
    fi
else
    echo "MYSQL is already installed....Nothing to do"

fi

#     dnf install mysql -y

#     if [ $? -eq 0 ]
# then

#     echo "Installing MYSQL is ......SUCCESS"
# else
#     echo Installing MYSQL is ....... FILURE"
#     exit 1

# fi


    