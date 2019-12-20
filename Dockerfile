FROM python:3.8-alpine

RUN apk add --update \
        fish perl figlet fortune jq tzdata curl binutils \
    && rm -rf /var/cache/apk/*

# Recent versions of fish force --color=always
RUN rm -f /usr/share/fish/functions/ls.fish

RUN pip3 install --no-cache-dir matrix_client

RUN curl -sSL https://github.com/fcambus/ansiweather/releases/download/1.15.0/ansiweather-1.15.0.tar.gz \
    | tar xfz - --strip-components=1 -C /usr/local/bin/ -- ansiweather-1.15.0/ansiweather

RUN curl -sSL https://github.com/tnalpgge/rank-amateur-cowsay/archive/cowsay-3.04.tar.gz \
    | tar xfz - -C /usr/src \
    && cd /usr/src/rank-amateur-cowsay-cowsay-3.04 \
    && ./install.sh

RUN mkdir /usr/src/cowsay-buster \
    && cd /usr/src/cowsay-buster \
    && curl -sSL http://http.us.debian.org/debian/pool/main/c/cowsay/cowsay_3.03+dfsg2-6_all.deb -o cowsay.deb \
    && ar x cowsay.deb data.tar.xz \
    && tar xfJ data.tar.xz --strip-components=5 -C /usr/local/share/cows/ -- ./usr/share/cowsay/cows/


COPY cows/* /usr/local/share/cows/

WORKDIR /irsh
CMD /irsh/init
