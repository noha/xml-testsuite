#!/usr/bin/env bash

###
# simple testsuite for running xml tests. 
# 
# Each given test file is associated with an XML schema and a status if the test should
# pass or fail. 
# 
# Author: Norbert Hartl <norbert@hartl.name>
###

if [ "$1" == "" ];
then
   echo "usage: $0 file1 file2 ..."
   exit 1
fi

# load schema configuration from current working directory
source schema-config

for filename in "$@";
do
   # detect the schema from filename
   for key in ${!schemas[@]}
   do 
      echo $filename | grep "$key" > /dev/null
      if [ "$?" == "0" ];
      then
         SCHEMA=${schemas[$key]}
      fi
   done

   if [ "$SCHEMA" == "" ];
   then
      echo "$filename does not match a schema. ignoring..."
   else

      # detect if the test should pass or fail
      echo $filename | grep "invalid" > /dev/null
      if [ "$?" == 0 ];
      then
         SHOULDFAIL="1"
      else
         SHOULDFAIL="0"
      fi

      RESULT=$(xmllint --schema $SCHEMA $filename 2>&1 > /dev/null )

      # reduce exit status of xmllint to a canonical form
      if [ "$?" == "0" ]; 
      then
         STATUS=0
      else
         STATUS=1
      fi

      # test if actual state and configured state are the same
      if [ "$SHOULDFAIL" == "$STATUS" ];
      then
         echo  "OK   $filename"
      else
         echo "---------------"
         echo "FAIL $filename"
         echo $RESULT
         echo "---------------"
      fi
   fi
done

