FROM debian:stable

RUN apt-get update && apt-get install -y git sudo
# Add a normal user with sudo that we can test against
RUN adduser testuser --disabled-password --gecos "" && adduser testuser sudo
# Make sudo work without a password
RUN echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/testuser
# This probably isn't how docker was meant to be used at all... oh well.
# execute:
#     dokcer build -t config .
#     docker run -i -t config /bin/bash
