FROM flyinprogrammer/ujava
MAINTAINER Alan Schegrer <flyinprogrammer@gmail.com>

ENV ZK_VERSION=3.4.6 \
    EXHIBITOR_BRANCH=master \
    EXHIBITOR_VERSION=1.5.6 \
    PATH=${PATH}:/opt/zk/bin:/opt/mvn/bin

RUN mkdir -p /opt/zk /opt/zk/transactions /opt/zk/snapshots && \
    curl -Lo /tmp/zk.tar.gz \
    http://www.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz && \
    tar -xzf /tmp/zk.tar.gz -C /opt/zk --strip=1 && \
    rm -rf /tmp/*

RUN apt-get update && \
    apt-get install -y git && \
    mkdir -p /opt/src && \
    cd /opt/src && \
    git clone --depth 1 https://github.com/flyinprogrammer/exhibitor.git && \
    cd exhibitor && \
    git checkout ${EXHIBITOR_BRANCH} && \
    ./gradlew -Prelease.version=${EXHIBITOR_VERSION} install && \
    cd exhibitor-standalone/src/main/resources/buildscripts/standalone/gradle/ && \
    ../../../../../../../gradlew shadowJar && \
    mkdir -p /opt/exhibitor && \
    mv build/libs/exhibitor-${EXHIBITOR_VERSION}-all.jar /opt/exhibitor/exhibitor.jar && \
    apt-get purge -y git && \
    apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ \
           /opt/src \
           $HOME/.gradle \
           $HOME/.m2

ADD wrapper.sh /opt/exhibitor/wrapper.sh
ADD zk.log4j.properties /opt/zk/conf/log4j.properties

USER root
WORKDIR /opt/exhibitor
EXPOSE 2181 2888 3888 8181

CMD ["bash", "-e", "/opt/exhibitor/wrapper.sh"]
