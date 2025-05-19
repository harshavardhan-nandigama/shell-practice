#!/bin/bash

echo "All varialbes passed to the script: $@"

echo "Number of variables: $#"

echo "Current directory: $PWD"

echo "User running this script: $USER"
echo "Home directory of user: $HOME"
echo "PID of the script: $$"
sleep 10&
echo "PID of last command in background: $!"