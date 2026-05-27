# Stage 1: Build the application using Apache Ant
FROM eclipse-temurin:17-jdk-jammy AS build

# Install Ant
RUN apt-get update && apt-get install -y ant

# Set the working directory
WORKDIR /app

# Copy all project files into the container
COPY . .

# Run the Ant build (this will compile code and generate the .war file in dist/)
# We assume your build.xml creates dist/HipZi.war or something similar.
RUN ant clean dist

# Stage 2: Create the runtime image with Tomcat
FROM tomcat:9.0-jdk17

# Remove default Tomcat apps to keep it clean and map our app to the root domain (/)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the compiled .war file from the build stage to Tomcat's webapps directory as ROOT.war
# (ROOT.war means it will run on your domain directly, e.g. hipzi.com/ instead of hipzi.com/HipZi)
COPY --from=build /app/dist/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
