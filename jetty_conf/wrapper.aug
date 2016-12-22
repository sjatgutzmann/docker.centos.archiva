set /files/opt/archiva/conf/wrapper.conf/wrapper.java.classpath.27 = "%REPO_DIR%/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar"
set /files/opt/archiva/conf/wrapper.conf/wrapper.java.classpath.28 = "%REPO_DIR%/postgresql-${POSTGRESQL_JDBC_VERSION}.jar"
set /files/opt/archiva/conf/wrapper.conf/wrapper.java.additional.3 = "-Dlog4j.configurationFile=%ARCHIVA_BASE%/conf/log4j2.xml"
set /files/opt/archiva/conf/wrapper.conf/wrapper.java.additional.9 = "-Djetty.port=${HTTP_PORT}"
save

