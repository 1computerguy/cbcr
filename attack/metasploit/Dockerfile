FROM metasploitframework/metasploit-framework:latest

RUN apk add --no-cache iproute2

ENTRYPOINT ["docker/entrypoint.sh"]

CMD ["./msfconsole", "-r", "docker/msfconsole.rc", "-y", "$APP_HOME/config/database.yml"]