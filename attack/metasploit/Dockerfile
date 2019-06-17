FROM metasploitframework/metasploit-framework:latest

RUN apk add --no-cache iproute2

ADD "docker/entrypoint.sh" "docker/entrypoint.sh"
ADD "database.yml" "$APP_HOME/config/database.yml"

RUN chmod +x docker/entrypoint.sh && \
    chown root:metasploit docker/entrypoint.sh

ENTRYPOINT docker/entrypoint.sh

