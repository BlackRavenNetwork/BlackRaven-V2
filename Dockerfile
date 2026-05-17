# BlackRaven Core daemon (multi-stage; use depends cache on host for faster CI)
FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 \
    libevent-dev libboost-all-dev libssl-dev libzmq3-dev libdb-dev libdb++-dev \
    git ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . .
RUN ./autogen.sh && ./configure --without-gui --disable-tests --disable-bench && \
    make -j"$(nproc)" -C src blackravend

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    libevent-2.1-7 libboost-system1.74.0 libboost-filesystem1.74.0 libboost-thread1.74.0 \
    libboost-chrono1.74.0 libssl3 libzmq5 libdb5.3++ && rm -rf /var/lib/apt/lists/*
COPY --from=builder /src/src/blackravend /usr/local/bin/
VOLUME ["/data"]
EXPOSE 9777 9776
ENTRYPOINT ["blackravend", "-datadir=/data", "-printtoconsole"]
