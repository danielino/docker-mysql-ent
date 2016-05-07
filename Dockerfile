FROM centos:7

# Update
#RUN yum -y distro-sync
RUN yum -y install --nogpgcheck  yum-utils \
	supervisor \
	hostname \
	iproute \
	perl-Data-Dumper \
	sysvinit-tools \
	unzip \
	wget \
	libaio \
	net-tools \
	numactl-libs

# Download software
RUN wget http://www.par-tec.it/RPMS/mysql-server-enterprise.zip
RUN wget http://danielino.ddns.net/repos/mysql/mysql-utilities.zip
RUN wget http://danielino.ddns.net/repos/mysql/mysql-connector-python-commercial.zip
RUN unzip mysql-server-enterprise.zip
RUN unzip mysql-connector-python-commercial.zip
RUN unzip MySQL-utilities.zip

# Install database rpm's

RUN rpm -ivh mysql-commercial-libs-*.rpm \
		mysql-commercial-common-5.7.12-1.1.el7.x86_64.rpm \
		mysql-commercial-client-5.7.12-1.1.el7.x86_64.rpm \
		mysql-commercial-server-5.7.12-1.1.el7.x86_64.rpm \
		mysql-connector-python-commercial-*.rpm \
		mysql-utilities-commercial-*.rpm
		


# Remove all packages from image
RUN yum -y clean all

RUN rm /var/lib/mysql/* -fr
RUN rm /var/lib/mysql-files/* -fr

VOLUME /var/lib/mysql
VOLUME /var/lib/mysql-files
VOLUME /backup

RUN useradd backup -d /backup -g mysql
RUN chown -R mysql:mysql /var/lib/mysql
RUN chown -R backup:mysql /backup

COPY ./my.cnf /etc/
COPY ./docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY ./Dockerfile /Dockerfile

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 3306
CMD ["mysqld"]
