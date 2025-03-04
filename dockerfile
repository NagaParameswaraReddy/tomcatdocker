FROM amazonlinux

# Install dependencies in one RUN command to minimize layers
RUN yum update -y && \
    yum install -y java tar gzip wget && \
    yum clean all

# Set working directory to /opt
WORKDIR /opt

# Download and extract Tomcat
RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.100/bin/apache-tomcat-9.0.100.tar.gz -O apache-tomcat.tar.gz && \
    tar -xvf apache-tomcat.tar.gz && \
    rm apache-tomcat.tar.gz

# Modify context.xml for manager app access (allow all hosts)
RUN sed -i 's/127\.\d\+\.\d\+\.\d\+|::1|0:0:0:0:0:0:0:1/.*/g' /opt/apache-tomcat-9.0.100/webapps/manager/META-INF/context.xml

# Configure Tomcat users for Manager and other roles (ensure roles are set correctly)
WORKDIR /opt/apache-tomcat-9.0.100/conf/
RUN rm -rf tomcat-users.xml
RUN echo '<?xml version="1.0" encoding="utf-8"?> \
<tomcat-users> \
  <role rolename="manager-gui"/> \
  <role rolename="manager-script"/> \
  <role rolename="manager-status"/> \
  <user username="tomcat" password="Tomcat" roles="manager-gui, manager-script, manager-status"/> \
</tomcat-users>' > tomcat-users.xml

# Expose Tomcat's default HTTP port
EXPOSE 8080

# Run Tomcat in the foreground (use catalina.sh for startup)
