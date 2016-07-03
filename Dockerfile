FROM ubuntu:14.04

# dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y socat man gcc

WORKDIR /opt/wtf.sh

# Create users
# web user -- everything will run under this one
RUN adduser --disabled-password --gecos '' www
# flag1 user -- flag1 will be owned by this, read_flag1 will setuid to be this
RUN adduser --disabled-password --gecos '' flag1
# flag2 user -- flag2 will be owned by this, read_flag2 will setuid to be this
RUN adduser --disabled-password --gecos '' flag2


# setup flags
COPY ./flag1.txt /home/flag1/
COPY ./flag2.txt /home/flag2/
RUN chown -R root:root /home/flag1/
RUN chown -R root:root /home/flag2/
RUN chown root:flag1 /home/flag1/flag1.txt
RUN chown root:flag2 /home/flag2/flag2.txt

RUN chmod 440 /home/flag1/flag1.txt
RUN chmod 440 /home/flag2/flag2.txt

# setgid programs to read flags
COPY ./get_flag1.c /tmp/
COPY ./get_flag2.c /tmp/
RUN gcc /tmp/get_flag1.c -o /usr/bin/get_flag1
RUN gcc /tmp/get_flag2.c -o /usr/bin/get_flag2
RUN chown root:flag1 /usr/bin/get_flag1
RUN chown root:flag2 /usr/bin/get_flag2

RUN chmod 2755 /usr/bin/get_flag1
RUN chmod 2755 /usr/bin/get_flag2


# assorted permissions
RUN chmod 1733 /tmp /var/tmp /dev/shm
# TODO: Resource limits


# setup webapp
COPY ./src /opt/wtf.sh
COPY ./setup_data.sh /tmp/setup_data.sh
RUN /tmp/setup_data.sh

RUN chown -R www /opt/wtf.sh


CMD su www -c "/opt/wtf.sh/wtf.sh 8000"
