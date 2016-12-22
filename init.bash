#!/bin/bash

	echo -n "begin init?"
if $DO_INIT
then
	echo " yes"
	source /data_dirs.env
	
	
	
	mkdir -p /archiva-data
	cd /opt/archiva
	
	
	# https://raw.githubusercontent.com/apache/archiva/master/archiva-cli/src/main/resources/log4j2.xml
	cp -f ${JETTY_CONF_PATH}/log4j2.xml conf/log4j2.xml

	# using augtool to 
	augtool -At "Properties.lns incl /opt/archiva/conf/wrapper.conf" <<ENDOFAUG
set /files/opt/archiva/conf/wrapper.conf/wrapper.java.classpath.27 %REPO_DIR%/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar
set /files/opt/archiva/conf/wrapper.conf/wrapper.java.classpath.28 %REPO_DIR%/postgresql-${POSTGRESQL_JDBC_VERSION}.jar
set /files/opt/archiva/conf/wrapper.conf/wrapper.java.additional.3 -Dlog4j.configurationFile=%ARCHIVA_BASE%/conf/log4j2.xml
set /files/opt/archiva/conf/wrapper.conf/wrapper.java.additional.9 -Djetty.port=${HTTP_PORT}
save	
ENDOFAUG

	# Add mysql-connect lib
#	sed -i "44i\
#	wrapper.java.classpath.27=%REPO_DIR%/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar" conf/wrapper.conf
#	sed -i "45i\
#	wrapper.java.classpath.28=%REPO_DIR%/postgresql-${POSTGRESQL_JDBC_VERSION}.jar" conf/wrapper.conf
    
	#overwrite all loggings to the console
#	sed -i "54c\
#	wrapper.java.additional.3=-Dlog4j.configurationFile=%ARCHIVA_BASE%/conf/log4j2.xml" conf/wrapper.conf

#	sed -i "60i\
#	wrapper.java.additional.9=-Djetty.port=${HTTP_PORT}" conf/wrapper.conf
	
	for datadir in "${DATA_DIRS[@]}"; do
	  if [ -e $datadir ]
	  then
		mv ${datadir} ${datadir}-template
	  fi
	  ln -s /archiva-data/${datadir#/*} ${datadir}
	done
	
	# move togto std.out
	# https://gist.github.com/afolarin/a2ac14231d9079920864
	#ln -sf /dev/stdout logs/archiva.log
	
	chown -R archiva:archiva /archiva-data/
	
	if [ -e ${JAVA_HOME}/jre/lib/security ]
	then
		chgrp archiva ${JAVA_HOME}/jre/lib/security
		chmod 664 ${JAVA_HOME}/jre/lib/security
	fi
else
	echo " no"
fi