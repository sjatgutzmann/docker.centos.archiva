#!/bin/bash

source /data_dirs.env

mkdir -p /archiva-data
cd /opt/archiva

# Add mysql-connect lib
sed -i "44i\
wrapper.java.classpath.27=%REPO_DIR%/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar" conf/wrapper.conf
sed -i "45i\
wrapper.java.classpath.28=%REPO_DIR%/postgresql-${POSTGRESQL_JDBC_VERSION}.jar" conf/wrapper.conf
sed -i "60i\
wrapper.java.additional.3=-Djetty.port=${HTTP_PORT}" conf/wrapper.conf

for datadir in "${DATA_DIRS[@]}"; do
  if [ -e $datadir ]
  then
    mv ${datadir} ${datadir}-template
  fi
  ln -s /archiva-data/${datadir#/*} ${datadir}
done

chown -R archiva:archiva /archiva-data/

if [ -e ${JAVA_HOME}/jre/lib/security ]
then
	chgrp archiva ${JAVA_HOME}/jre/lib/security
	chmod 664 ${JAVA_HOME}/jre/lib/security
fi
