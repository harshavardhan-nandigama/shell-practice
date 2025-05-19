#!/bin/bash

NUMBER=$1

# -gt --> greaterthan
# -lt --> lessthan
# -eq --> equal
# -ne --> not equal

if [ $NUMBER -lt 10]
then
    echo "given number $NUMBER is less than 10"
else
    echo "Given number $NUMBER is not less than 10"
fi