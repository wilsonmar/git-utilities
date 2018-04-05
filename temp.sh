#!/usr/local/bin/bash

java -version
JAVA_VERSION=$(java -version | grep "java version")
#java version "1.8.0_162"
#Java(TM) SE Runtime Environment (build 1.8.0_162-b12)
#Java HotSpot(TM) 64-Bit Server VM (build 25.162-b12, mixed mode)
echo "JAVA_VERSION=$JAVA_VERSION"

# /Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home
java_version=1.8.0_121
export IDEA_JDK=$(/usr/libexec/java_home -v $java_version)
export RUBYMINE_JDK=$(/usr/libexec/java_home -v $java_version)
export JDK_HOME=$(/usr/libexec/java_home -v $java_version)
export JAVA_HOME=$(/usr/libexec/java_home -v $java_version)