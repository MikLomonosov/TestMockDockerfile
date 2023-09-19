FROM alpine/git AS clone
ARG url
WORKDIR /app
RUN git clone ${url}

FROM maven:3.6.3-jdk-11 AS build
ARG project
WORKDIR /app
COPY --from=clone /app/${project} /app
RUN mvn install

FROM openjdk:11-jre
ARG artifactid
ARG version
ENV artifact ${artifactid}-${version}.jar
RUN apt update\
 && apt-get install -y wget
WORKDIR /app
RUN wget http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/1.7.2/jolokia-jvm-1.7.2.jar -O /app/jolokia.jar
COPY --from=build /app/target/${artifact} /app
EXPOSE 8080
EXPOSE 8778
ENTRYPOINT ["sh", "-c"]
CMD ["java -jar -javaagent:jolokia.jar=port=8778,host=0.0.0.0 ${artifact}"]
