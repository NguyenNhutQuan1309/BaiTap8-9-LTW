# ============================================================
# Build stage: build the three independent Maven WAR projects
# ============================================================
FROM maven:3.9.16-eclipse-temurin-17 AS build

# Exercise 8 - Email List
WORKDIR /workspace/email-list
COPY 02_SOLUTION_DapAn/Bai8/Bai8_Exercise8-1_EmailList/pom.xml ./pom.xml
COPY 02_SOLUTION_DapAn/Bai8/Bai8_Exercise8-1_EmailList/src ./src
RUN mvn -B -ntp clean package -DskipTests

# Exercise 9-1 - Download
WORKDIR /workspace/download
COPY 02_SOLUTION_DapAn/Bai9/Bai9_Exercise9-1_Download/pom.xml ./pom.xml
COPY 02_SOLUTION_DapAn/Bai9/Bai9_Exercise9-1_Download/src ./src
RUN mvn -B -ntp clean package -DskipTests

# Exercise 9-2 - Cart
WORKDIR /workspace/cart
COPY 02_SOLUTION_DapAn/Bai9/Bai9_Exercise9-2_Cart/pom.xml ./pom.xml
COPY 02_SOLUTION_DapAn/Bai9/Bai9_Exercise9-2_Cart/src ./src
RUN mvn -B -ntp clean package -DskipTests

# ============================================================
# Runtime stage: one Tomcat hosts all three web applications
# ============================================================
FROM tomcat:10.1.62-jdk17-temurin-jammy

ENV PORT=10000

# Remove Tomcat's sample applications and create the landing page.
RUN rm -rf /usr/local/tomcat/webapps/* \
    && mkdir -p /usr/local/tomcat/webapps/ROOT

# Each WAR filename defines its context path:
# /email-list, /download, and /cart.
COPY --from=build /workspace/email-list/target/bai8-email-solution.war \
    /usr/local/tomcat/webapps/email-list.war
COPY --from=build /workspace/download/target/bai9-download-solution.war \
    /usr/local/tomcat/webapps/download.war
COPY --from=build /workspace/cart/target/bai9-cart-solution.war \
    /usr/local/tomcat/webapps/cart.war

# The ROOT application is a small index page linking to all exercises.
COPY render-home/index.html /usr/local/tomcat/webapps/ROOT/index.html

EXPOSE 10000

# Render supplies PORT. Tomcat must listen on 0.0.0.0:$PORT.
CMD ["sh", "-c", "PORT=\"${PORT:-10000}\"; sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT}\\\" address=\\\"0.0.0.0\\\"/\" /usr/local/tomcat/conf/server.xml; exec catalina.sh run"]
