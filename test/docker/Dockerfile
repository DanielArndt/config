FROM debian:stable

RUN apt-get update && apt-get install -y git sudo python
# Add a normal user with sudo that we can test against
RUN adduser testuser --disabled-password --gecos "" && adduser testuser sudo
# Make sudo work without a password
RUN echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/testuser
# Use the digitalocean mirrors
RUN sed -i 's/deb http:\/\/httpredir\.debian\.org/deb http:\/\/mirrors\.digitalocean\.com/' /etc/apt/sources.list
# This probably isn't how docker was meant to be used at all... oh well.
# execute:
#     dokcer build -t config .
#     docker run -i -t config /bin/bash
