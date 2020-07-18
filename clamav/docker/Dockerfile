FROM centos:7
MAINTAINER Mauricio Melendez. Kevin Gomez. 
RUN yum update -y
RUN yum install openssl deltarpm rpm-build rpmdevtools openssl-devel libcurl-devel zlib zlib-devel libpng-devel libxml2-devel json-c-devel bzip2-devel pcre2-devel ncurses-devel valgrind check wget -y
RUN yum groupinstall "Development Tools" -y
WORKDIR /root
COPY clamav.spec /root
RUN rpmdev-setuptree && echo "%_unpackaged_files_terminate_build      0" >> /root/.rpmmacros && echo "%_binaries_in_noarch_packages_terminate_build   0" >> /root/.rpmmacros && wget https://www.clamav.net/downloads/production/clamav-0.101.2.tar.gz && mv clamav-0.101.2.tar.gz  /root/rpmbuild/SOURCES/ && mv clamav.spec /root/rpmbuild/SPECS/
CMD ["/bin/bash","-c","rpmbuild -ba /root/rpmbuild/SPECS/clamav.spec"]
VOLUME [ "/root/rpmbuild/RPMS/" ]