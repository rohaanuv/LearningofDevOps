FROM tomcat:9.0.73-jdk8-temurin

WORKDIR /usr/local/tomcat/webapps/

COPY /JavaAuthApp/target/LoginWebApp.war  .

EXPOSE 8080

CMD ["catalina.sh", "run"] 