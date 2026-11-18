# ==========================================
# STAGE 1: BUILD APPLICATION
# ==========================================

FROM eclipse-temurin:25-jdk AS builder

WORKDIR /workspace

# Copy Maven configuration first for dependency caching
COPY mvnw pom.xml ./
COPY .mvn/ .mvn/

# Make Maven Wrapper executable
RUN chmod +x mvnw

# Download dependencies
RUN ./mvnw -B dependency:go-offline

# Copy application source code
COPY src/ src/

# Build application and execute tests
RUN ./mvnw -B clean package -Dmaven.test.skip=true

# ==========================================
# STAGE 2: RUNTIME APPLICATION
# ==========================================

FROM eclipse-temurin:25-jre AS runtime

WORKDIR /app

# Configure application port
ENV SERVER_PORT=8080

EXPOSE 8080

# Copy only the executable JAR from builder
COPY --from=builder --chown=10001:10001 \
    /workspace/target/student-app.jar /app/student-service.jar

# Run as non-root user
USER 10001:10001

# Start Spring Boot
ENTRYPOINT ["java", "-jar", "/app/student-service.jar"]
