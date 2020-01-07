FROM picoded/ubuntu-openjdk-8-jdk
RUN mkdir /images
ENV initdb=true
ENV initImgPath=/initimages
ENV imgpath=/images
ENV openalpr=/usr/share/openalpr
COPY back.jar back.jar
RUN apt-get update && apt-get install -y wget
RUN wget -O - http://deb.openalpr.com/openalpr.gpg.key | sudo apt-key add -
RUN echo "deb http://deb.openalpr.com/master/ openalpr main" | sudo tee /etc/apt/sources.list.d/openalpr.list
RUN sudo apt-get --assume-yes install openalpr openalpr-daemon openalpr-utils libopenalpr-dev
COPY default.conf /usr/share/openalpr/runtime_data/config/default.conf
COPY initimages /initimages
ENTRYPOINT ["java", "-Dspring.data.mongodb.host=mongodb", "-jar", "back.jar"]
