FROM eclipse-temurin:17
RUN mkdir /opt/app
COPY target/spring-boot-web.jar /opt/app
CMD ["java", "-jar", "/opt/app/spring-boot-web.jar"]
