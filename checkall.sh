#!/bin/sh

# checkall.sh in # From http://github.com/wilsonmar/git-utilities
# Based on http://steve-parker.org/sh/functions.shtml

# Before calling this, run: chmod a+x checkall.sh
# Call from   command line: ./rn checkall.sh

NOW=$(date)
echo "***** ${NOW}."

HOST="https://github.com/wilsonmar"

checkone()
{
echo "_"
echo "***** REPO=${HOST}/${REPO} ******"
cd ${REPO}
git status
git fetch
cd ..
}

# Move up
# cd ..

# Do each (alphabetically):
REPO="git-utilities"
checkone 

REPO="oss-perf"
checkone 

REPO="SAP-HANA"
checkone 

REPO="scala"
checkone 

REPO="word-processing"
checkone

# Move back down
#cd git-utilities

echo "******"
