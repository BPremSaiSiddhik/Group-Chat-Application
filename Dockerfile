FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copy Maven wrapper and pom first for caching dependencies
COPY mvnw .
COPY .mvn .mvn
RUN chmod +x mvnw

COPY pom.xml .
RUN ./mvnw dependency:go-offline -B

# Now copy the rest of the source
COPY src src
RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Render automatically injects PORT env var
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
