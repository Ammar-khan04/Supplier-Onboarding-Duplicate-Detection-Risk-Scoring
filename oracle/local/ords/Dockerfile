FROM eclipse-temurin:21-jre-jammy

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl netcat-openbsd unzip \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ords /opt/oracle-tools /var/log/ords \
  && curl -L -o /tmp/ords.zip https://download.oracle.com/otn_software/java/ords/ords-latest.zip \
  && unzip -q /tmp/ords.zip -d /opt/ords \
  && rm /tmp/ords.zip \
  && chmod +x /opt/ords/bin/ords \
  && curl -L -o /tmp/sqlcl.zip https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip \
  && unzip -q /tmp/sqlcl.zip -d /opt/oracle-tools \
  && rm /tmp/sqlcl.zip \
  && chmod +x /opt/oracle-tools/sqlcl/bin/sql

ENV PATH="/opt/ords/bin:/opt/oracle-tools/sqlcl/bin:${PATH}"

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
