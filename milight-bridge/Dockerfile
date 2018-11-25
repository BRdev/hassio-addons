ARG BUILD_FROM
FROM $BUILD_FROM

# install java 8
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update && apt-get install -y nodejs
RUN apt-get update && apt-get install -y npm

# install milightsbridge
RUN git clone https://github.com/KevinVR/milights-bridge.git
RUN cd milights-bridge
RUN npm install
RUN cp config.example.js config.js
RUN node server.js
