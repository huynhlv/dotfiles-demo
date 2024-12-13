#!/bin/bash

option=$1
prefix=$2
branch=$3

GREEN='\033[0;32m'
NC='\033[0m'

if [ $option = '-b' ]
then
  olticket=$(echo $branch| cut -d'-' -f 2)
  if [[ $branch == *"OL"* ]]
  then
    branch="OL-${olticket}"
  fi
  basebranch=$(git branch --show-current)
  if [[ ! $basebranch =~ ^(fix/|feat/) ]]
  then
    echo "BASEBRANCH=${basebranch}" > ~/Dev/subline-text/bashjs/soucebase.txt
    echo -e "${GREEN}Base Branch: $basebranch${NC}"
  fi
  git checkout $option "${prefix}/${branch}"
else
  branch=$option
  # git checkout $branch
fi
