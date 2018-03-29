#!/usr/local/bin/bash
temp.sh

   if [ ! -d "/Applications/Firefox.app" ]; then 
       echo "Installing GIT_BROWSER=\"firefox\" using Homebrew ..."
   else
       echo "GIT_BROWSER=\"firefox\" already installed."
   fi
