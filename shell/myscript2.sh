#!/bin/bash
a=$1
b=$2

# SH Syntax
if [ $a -lt $b ]; then
  echo "$a is less than $b"
fi

# Bash Syntax
if [[ $a -lt $b ]]; then
  echo "$a is less than $b"
fi
