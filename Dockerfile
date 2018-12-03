#FROM openjdk:8-jdk-alpine
#ENV PORT 8080
#EXPOSE 8080
#COPY target/*.jar /opt/app.jar
#WORKDIR /opt
#ENTRYPOINT exec java $JAVA_OPTS -jar app.jar

FROM openjdk:8-jdk-alpine as build
WORKDIR /workspace/app

COPY target target

RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG DEPENDENCY=/workspace/app/target/dependency

COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/org/springframework/boot/loader /app/org/springframework/boot/loader
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

ENV JAVA_OPTS=""

ENV PORT 8080
EXPOSE 8080

ENTRYPOINT exec java -noverify $JAVA_OPTS \
		-cp app:app/lib/* \
		-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap \
		-Djava.security.egd=file:/dev/./urandom  \
		org.springframework.boot.loader.JarLauncher