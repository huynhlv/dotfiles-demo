#!/bin/bash

path=$1
envstr=$2
prefix=$3
ticket=$4
commitstr=$5

IFS=', ' read -r -a commitarr <<< "$commitstr"
IFS=', ' read -r -a envarr <<< "$envstr"

GREEN='\033[0;32m'
NC='\033[0m'

if [ $path = 'core' ]
then
  path=$OLIVIA_CORE
  repo='olivia-core'
else
  path=$OLIVIA_UI
  repo='olivia'
fi

giturl="https://github.com/ParadoxAi/${repo}/compare"

echo -e "${GREEN}Path: $path${NC}"
echo -e "${GREEN}Todo: $prefix${NC}"
echo -e "${GREEN}Ticket: $ticket${NC}"

cd $path || exit

git fetch -q

for env in "${envarr[@]}"
do
    echo -e "${GREEN}Env: $env${NC}"
    if [ $prefix = 'pick' ]
    then
      newbranch="${prefix}/${ticket}_${env}"
    else
      newbranch="${prefix}/${ticket}"
    fi
    git cherry-pick --abort
    git checkout "$env" && git reset --hard origin/$env && git pull
    git branch -D "$newbranch"
    git checkout -b "$newbranch"

    for commit in "${commitarr[@]}"
    do
        git cherry-pick $commit
        echo -e "${GREEN}Commit: $commit${NC}"
    done
    git status
    git push -f origin $newbranch
    echo -e "${GREEN}Branch: $newbranch${NC}"
    echo -e "${GREEN}Jirra: https://paradoxai.atlassian.net/browse/${ticket}${NC}"
    echo -e "${GREEN}URL: ${giturl}/${env}...${newbranch}?expand=1${NC}"
done
