FROM tomcat

RUN yum install java-1 -y

RUN yum install 

WORKDIR /usr/local/tomcat/webapp

COPY game-of-life ./

RUN mvn clean install