FROM metasploitframework/metasploit-framework:latest

RUN apk add --no-cache iproute2

ADD "docker/entrypoint.sh" "docker/entrypoint.sh"
ADD "database.yml" "$APP_HOME/config/database.yml"

RUN chmod +x docker/entrypoint.sh && \
    chown root:metasploit docker/entrypoint.sh

ENTRYPOINT docker/entrypoint.sh

#CMD ["./msfconsole", "-r", "docker/msfconsole.rc", "-y", "$APP_HOME/config/database.yml"]
#CMD [ "./msfd", "-a", "0.0.0.0"]
#CMD [ "msfrpcd", "-U",  "admin", "-P", "P@55w0rd!", "-f" ]
