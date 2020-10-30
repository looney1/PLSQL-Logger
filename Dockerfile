FROM openjdk:11-jdk-slim

ENV LIQUIBASE_VERSION=3.10.0
ENV LIQUIBASE_GROOVY_DSL=2.1.2
ENV GROOVY_VERSION=3.0.4
ENV OJDBC_VERSION=8

RUN set -x && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends tar gzip bash && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /liquibase/lib

WORKDIR /liquibase

ADD https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz /liquibase
ADD https://repo1.maven.org/maven2/org/codehaus/groovy/groovy/${GROOVY_VERSION}/groovy-${GROOVY_VERSION}.jar /liquibase/lib
ADD https://repo1.maven.org/maven2/org/codehaus/groovy/groovy-sql/${GROOVY_VERSION}/groovy-sql-${GROOVY_VERSION}.jar /liquibase/lib
ADD https://repo1.maven.org/maven2/org/codehaus/janino/janino/3.1.2/janino-3.1.2.jar /liquibase/lib
ADD https://repo1.maven.org/maven2/org/codehaus/janino/commons-compiler/3.1.2/commons-compiler-3.1.2.jar /liquibase/lib
ADD https://broadinstitute.jfrog.io/broadinstitute/simple/libs-release/org/liquibase/liquibase-groovy-dsl/${LIQUIBASE_GROOVY_DSL}/liquibase-groovy-dsl-${LIQUIBASE_GROOVY_DSL}.jar /liquibase/lib

COPY ojdbc${OJDBC_VERSION}-full.tar.gz /liquibase/lib/ojdbc-full.tar.gz

RUN tar -xzf liquibase-${LIQUIBASE_VERSION}.tar.gz  && \
    rm -r liquibase.bat liquibase-${LIQUIBASE_VERSION}.tar.gz examples/ licenses/ *.txt && \
    tar -C /liquibase/lib/ -xzf /liquibase/lib/ojdbc-full.tar.gz --strip 2 && \
    rm -r /liquibase/lib/ojdbc-full.tar.gz

#COPY sample-migrations /migrations/
COPY migrations /migrations/

VOLUME /migrations
WORKDIR /migrations

ENTRYPOINT ["/liquibase/liquibase"]