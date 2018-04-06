#!/usr/local/bin/bash

#if [ -d "../$UTIL_REPO" ]; then #  already in
#   fancy_echo "Already in $UTIL_PROD"
#fi

   if ! python -c "import golem-framework">/dev/null 2>&1 ; then   
      # sudo pip install git-review
      echo "golem-framework not installed"; 
   else
      echo "golem-framework installed already."; 
   fi
