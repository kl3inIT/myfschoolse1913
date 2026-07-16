FROM eclipse-temurin:25-jdk-noble AS builder

WORKDIR /workspace
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle.kts settings.gradle.kts ./
RUN chmod +x gradlew
COPY src src
RUN ./gradlew --no-daemon clean bootJar -x test

FROM eclipse-temurin:25-jdk-noble

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /workspace/build/libs/*.jar /app/app.jar

USER 1000:1000
EXPOSE 8080

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.jar"]
