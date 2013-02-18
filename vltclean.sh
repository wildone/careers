#!/bin/bash

if [ "$1" = "" ] ; then
    echo Project is missing. Please use project name as argument, e.g.:
    echo vltclean.bat corporate
    exit
fi

echo running vltclean for project $1
echo Cleaning VLT files ...
find $1-ui -name ".vlt" -exec rm -rf {} \;
echo Building and installing FULL content package ...
mvn clean install -P $1,full -Dmaven.test.skip=true > mvn.log
if grep -q "BUILD SUCCESS" mvn.log; then
    rm mvn.log
    echo VLT checkout $1-ui ...
    cd $1-ui/src/main/content/jcr_root
    vlt --credentials admin:admin co http://localhost:4502/crx / . --force --quiet
    cd ../../../../..
    rm $1-ui/src/main/content/jcr_root/apps/$1/install/$1-*.jar 
    echo Cleanup finished.
else
    cat mvn.log
    echo Build was not successful, cleanup aborted.
fi

