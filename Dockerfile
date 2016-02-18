# Ubuntu 14.04 LTS
# Oracle Java 1.8.0_11 64 bit
# Maven 3.2.2
# Jenkins 1.574
# git 1.9.1
# Nano 2.2.6-1ubuntu1

# extend the most recent long term support Ubuntu version
FROM ubuntu:14.04

MAINTAINER Jonathan Camp (jonathan.camp@gmail.com)

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

RUN useradd -ms /bin/bash jenkins

# update dpkg repositories
RUN apt-get update && apt-get install -y wget docker.io curl python-pip build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfreetype6 libfreetype6-dev 

# get maven 3.2.2
RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz

# verify checksum
RUN echo "87e5cc81bc4ab9b83986b3e77e6b3095 /tmp/apache-maven-3.2.2.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.2.2.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.2.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.2.2.tar.gz
ENV MAVEN_HOME /opt/maven

# install git
RUN apt-get install -y git

# install nano
RUN apt-get install -y nano

# remove download archive files
RUN apt-get clean

# set shell variables for java installation
ENV java_version 1.8.0_72
ENV filename jdk-8u72-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u72-b15/$filename

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink 

# unpack java
RUN mkdir /opt/jdk1.8.0_51 && tar -zxf /tmp/$filename --strip-components 1 -C /opt/jdk1.8.0_51/
ENV JAVA_HOME /opt/jdk1.8.0_51
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# copy jenkins war file to the container
#ADD http://mirrors.jenkins-ci.org/war/latest/jenkins.war /opt/jenkins.war
ADD jenkins.war /opt/jenkins.war
RUN chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /jenkins

# make a directory owned by the user jenkins where we will mount our volume
RUN mkdir /jenkins && touch /jenkins/x && chown -R jenkins:jenkins /jenkins

# configure the container to run jenkins, mapping container port 8080 to that host port
ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
EXPOSE 8080

# look for git key in jenkins home
ADD ssh-config /home/jenkins/.ssh/config
ADD known_hosts /home/jenkins/.ssh/known_hosts
ADD id_rsa /home/jenkins/.ssh/id_rsa

RUN chown -R jenkins:jenkins /home/jenkins/.ssh
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
USER jenkins

ADD .dockercfg /home/jenkins/.dockercfg

CMD [""]
