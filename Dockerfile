FROM ubuntu:14.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y socat man

WORKDIR /opt/wtf.sh

# Create users
# web user -- everything will run under this one
RUN adduser --disabled-password --gecos '' www
# flag1 user -- flag1 will be owned by this, read_flag1 will setuid to be this
RUN adduser --disabled-password --gecos '' flag1
# flag2 user -- flag2 will be owned by this, read_flag2 will setuid to be this
RUN adduser --disabled-password --gecos '' flag2


COPY ./src /opt/wtf.sh
COPY ./setup_data.sh /tmp/setup_data.sh
RUN /tmp/setup_data.sh

RUN chown -R www /opt/wtf.sh

CMD su www -c "/opt/wtf.sh/wtf.sh 8000"
