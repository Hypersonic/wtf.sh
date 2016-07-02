FROM ubuntu:14.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y socat man

WORKDIR /opt/wtf.sh

COPY ./src /opt/wtf.sh
COPY ./setup_data.sh /tmp/setup_data.sh
RUN /tmp/setup_data.sh

CMD /opt/wtf.sh/wtf.sh 8000
