FROM ubuntu

RUN apt update

RUN apt install -y iputils-ping

CMD [ "/bin/bash" ]