# Multi-stage build
FROM maven:3.9.0-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-slim

WORKDIR /app

# Copy jar from builder
COPY --from=builder /app/target/*.jar app.jar

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD java -cp app.jar -c "import java.net.*; var conn = (HttpURLConnection) new URL(\"http://localhost:8080/api/items/health\").openConnection(); var status = conn.getResponseCode(); System.exit(status == 200 ? 0 : 1);" || exit 1

# Expose port
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
