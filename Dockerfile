# Use the official Tomcat image
FROM tomcat:9.0-jdk17

# Remove default Tomcat apps to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the PRE-BUILT .war file from the NetBeans dist folder directly into Tomcat
# We use ROOT.war so it runs at the root domain (/)
COPY dist/HipZi.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
