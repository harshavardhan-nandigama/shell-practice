#!/bin/bash

echo "All variables passed to the script: S@"
echo "Number of variables: $#"
echo "Script name: $0"
echo "Current Directory: $PWD"
echo "Home directory of user: $HOME
echo "PID of the script of user: $HOME"
sleep 10 &
echo "PID of last command in background: $!"
