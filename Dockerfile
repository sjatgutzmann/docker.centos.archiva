FROM sjatgutzmann/docker.centos.oraclejava8
MAINTAINER Sven Jörns <sjatgutzmann@gmail.com>

ENV VERSION 2.2.1
ARG HTTP_PORT=8080
ARG HTTPS_PORT=8443

ENV MYSQL_JDBC_VERSION="5.1.35"
ENV POSTGRESQL_JDBC_VERSION="9.4.1212"

# install usefull tools
RUN yum -y update; yum clean all \
 && yum -y install sudo epel-release sed net-tools less augeas\
# lanugae support
# reinstall glib to get all lanuages
 && yum -y reinstall glibc-common

#
# Go get the needed tar/jar we'll installing
#
RUN curl -sSLo /apache-archiva-$VERSION-bin.tar.gz http://archive.apache.org/dist/archiva/$VERSION/binaries/apache-archiva-$VERSION-bin.tar.gz \
  && tar --extract --ungzip --file apache-archiva-$VERSION-bin.tar.gz --directory / \
  && rm /apache-archiva-$VERSION-bin.tar.gz && mv /apache-archiva-$VERSION /opt/archiva \
  && curl -sSLo /opt/archiva/lib/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${MYSQL_JDBC_VERSION}/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar \
  && curl -sSLo /opt/archiva/lib/postgresql-${POSTGRESQL_JDBC_VERSION}.jar https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_VERSION}.jar

#
# Adjust ownership and Perform the data directory initialization
#
ADD data_dirs.env /data_dirs.env
ADD init.bash /init.bash
ADD jetty_conf /jetty_conf
# Sync calls are due to https://github.com/docker/docker/issues/9547
RUN useradd -d /opt/archiva/data -m archiva &&\
  cd /opt && chown -R archiva:archiva archiva &&\
  cd / && chown -R archiva:archiva /jetty_conf &&\
  chmod 755 /init.bash &&\
  sync && /init.bash &&\
  sync && rm /init.bash

#
# Add the bootstrap cmd
#
ADD run.bash /run.bash
RUN chmod 755 /run.bash

#
# All data is stored on the root data volume.
USER archiva

VOLUME ["/archiva-data"]

# Standard web ports exposted
EXPOSE ${HTTP_PORT}/tcp ${HTTPS_PORT}/tcp

ENTRYPOINT ["/run.bash"]
