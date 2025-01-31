FROM python:3.11-alpine

RUN apk add --update fish perl figlet fortune jq tzdata curl binutils coreutils \
    && apk add --update --virtual build-deps gcc libc-dev \
    && pip3 install --no-cache-dir matrix_nio bs4 markovify slackclient \
    && apk del build-deps \
    && rm -rf /var/cache/apk/*

# Recent versions of fish force --color=always
RUN rm -f /usr/share/fish/functions/ls.fish

RUN curl -sSL https://github.com/fcambus/ansiweather/releases/download/1.15.0/ansiweather-1.15.0.tar.gz \
    | tar xfz - --strip-components=1 -C /usr/local/bin/ -- ansiweather-1.15.0/ansiweather

RUN curl -sSL https://github.com/tnalpgge/rank-amateur-cowsay/archive/cowsay-3.04.tar.gz \
    | tar xfz - -C /usr/src \
    && cd /usr/src/rank-amateur-cowsay-cowsay-3.04 \
    && ./install.sh \
    && rm -rf /usr/src/rank-amateur-cowsay-cowsay-3.04

RUN mkdir /usr/src/cowsay-buster \
    && cd /usr/src/cowsay-buster \
    && curl -sSL http://http.us.debian.org/debian/pool/main/c/cowsay/cowsay_3.03+dfsg2-6_all.deb -o cowsay.deb \
    && ar x cowsay.deb data.tar.xz \
    && tar xfJ data.tar.xz --strip-components=5 -C /usr/local/share/cows/ -- ./usr/share/cowsay/cows/ \
    && rm -rf /usr/src/cowsay-buster

COPY cows/* /usr/local/share/cows/

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

WORKDIR /irsh
CMD /irsh/init
