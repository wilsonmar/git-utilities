#!/bin/bash
# extract-sample.sh

echo "sec   rsa2048/7FA75CBDD0C5721D 2018-03-22 [SC]" | awk -v FS="(rsa2048/| )" '{print $2}'

echo "------------"
echo 'abcdefg'|tail -c +2|head -c 3
# output bcd
echo "------------"

fancy_echo "more:"
asd=someletter8/12345_eleters.ext
echo `expr $asd : '.*8/\(.*\)_'`
echo "------------"

str="/Users/wilsonmar/.gnupg/pubring.kbx
sec   rsa2048/7FA75CBDD0C5721D 2018-03-22 [SC]
      12776C492E6CF8C725B2235C7FA75CBDD0C5721D
uid                 [ultimate] Wilson Mar (2 long enough passphrase) <WilsonMar+GitHub@gmail.com>
ssb   rsa2048/066F92FE88317144 2018-03-22 [E]"
echo "Extract GPG list between \"rsa2048/\" and \" 2018\" onward:"
   str=${str#*rsa2048/}
   str=${str%2018*}

   echo " "
   echo "Expected:"
   echo "KEY=7FA75CBDD0C5721D"
   echo " "
   echo "Actual:"
   echo "KEY=$str"

   echo " "
   echo "Note: text after 7FA75CBDD0C5721D should be gone."