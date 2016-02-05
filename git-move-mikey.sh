#!/usr/bin/env bash
set -euo pipefail  ## README -> http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'

# Log to syslog
exec 1> >(logger -s -t $(basename $0)) 2>&1

# System Variables
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SYSTEM=${OSTYPE//[0-9.]/}
HNAME=$(hostname)
TMP='/tmp/gitclonerepo'
REPO_A="http://github.com/wilsonmar/SampleA"
REPO_B="http://github.com/wilsonmar/SampleB"

rm -Rf ${TMP}
mkdir ${TMP}


function gg ()
{
   local _gg="$1";
   shift;
   git --git-dir="${_gg}/.git" --work-tree="${_gg}" "$@"
}

git clone ${REPO_A} ${TMP}/sampleA
#gg ${TMP}/sampleA remote rm origin
( cd ${TMP}/sampleA && git filter-branch --subdirectory-filter SampleA-folder1 -- --all)
mkdir ${TMP}/samplea-tmp-directory1
mv ${TMP}/sampleA/* ${TMP}/samplea-tmp-directory1/
mv ${TMP}/.git ${TMP}/samplea-tmp-directory1/
gg ${TMP}/samplea-tmp-directory1 git checkout -b SampleA-for-branchB
gg /tmp/gitclonerepo/samplea-tmp-directory1 git push origin SampleA-for-branchB

git clone ${REPO_B} ${TMP}/sampleB
gg ${TMP}/sampleB remote add repo-A-branch ${REPO_A}
gg ${TMP}/sampleB pull repo-A-branch SampleA-for-branchB
# gg ${TMP}/sampleB remote rm repo-A-branch