ROOT=$(shell pwd)
JAVA=$(shell which java | head -1)
JAVAC=$(shell which javacs | head -1)
JAVA_BUILD=${ROOT}/JAVA
ARCH=$(shell getconf LONG_BIT)
DIST_DIR=${ROOT}/BIN
BUILD_DIR=${ROOT}/BUILD

all: install serve

ifeq (${JAVAC},)
ifeq (${JAVA_HOME},)
ifeq ($(wildcard ${JAVA_BUILD}),)
ifeq (${ARCH},64)
JAVA_ARCH=x64
else
JAVA_ARCH=i586
endif
download-java: $(shell wget --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7/jdk-7-linux-${JAVA_ARCH}.tar.gz")
create-java-dir: $(shell mkdir -p ${JAVA_BUILD})
untar-java: $(shell tar -xvzf jdk-7-linux-${JAVA_ARCH}.tar.gz -C ${JAVA_BUILD})
delete-java-tar: $(shell rm jdk-7-linux-${JAVA_ARCH}.tar.gz)
endif
JAVA_HOME=${JAVA_BUILD}/jdk1.7.0
endif
endif

ifeq (${JAVA_HOME},)
JAVA_BIN=$(shell readlink -f ${JAVAC} | xargs dirname)
JAR=${JAVA_BIN}/jar
else
JAVA=${JAVA_HOME}/bin/java
JAVAC=${JAVA_HOME}/bin/javac
JAR=${JAVA_HOME}/bin/jar
endif


install: 
	$(shell rm -rf ${BUILD_DIR})
	$(shell mkdir ${BUILD_DIR})
	$(shell find ./src -name "*.java" > sources_list.txt)
	$(shell ${JAVAC} -classpath "${CLASSPATH}" @sources_list.txt)
	$(shell rm sources_list.txt)
	$(shell find ./src -name "*.class" > sources_list.txt)
	$(shell xargs -I dest -a sources_list.txt cp --parents dest ${BUILD_DIR})
	$(shell xargs -a sources_list.txt rm)
	$(shell rm sources_list.txt)
	$(shell rm -rf ${DIST_DIR})
	$(shell mkdir ${DIST_DIR})
	$(shell cd ${BUILD_DIR}/src && ${JAR} cf ${DIST_DIR}/stream-m.jar * && cd ../../)
	$(shell rm -rf ${BUILD_DIR})
	$(shell cp server.conf ${DIST_DIR})
	$(shell cd ${ROOT}/webclient && zip -r -q console * && mv console.zip ${DIST_DIR} && cd ../)
	
serve:
	$(shell cd ${DIST_DIR} && ${JAVA} -cp stream-m.jar StreamingServer server.conf)

