FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
    apt-get -y install python3 python3-pip fish cowsay figlet \
        fortune fortunes-off jq ansiweather locales tzdata \
        # hiptext dependencies
        git build-essential autoconf pkg-config libjpeg-dev \
        libavcodec-dev libavformat-dev libavutil-dev libgoogle-glog-dev \
        libpng-dev libswscale-dev libfreetype6-dev libgflags-dev ragel \
        && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir matrix_client bs4

ENV PATH="/usr/games:${PATH}"

# Python defaults IO to the system encoding
# Snippet from http://jaredmarkell.com/docker-and-locales/
RUN sed -i -e 's/# \(en_US.UTF-8 .*\)/\1/' /etc/locale.gen && \
    dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /usr/src/hiptext
RUN git clone --depth 1 https://github.com/scott-linder/hiptext .
RUN ./autogen.sh
RUN ./configure
RUN make -j4
RUN make install

WORKDIR /irsh
CMD /irsh/init
