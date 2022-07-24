FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

RUN sed 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch-=amd64,i386] http:\/\/ports.ubuntu.com\/ubuntu-ports\//g' /etc/apt/sources.list > /etc/apt/sources.list.d/ports.list
RUN sed -i 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch=amd64,i386] http:\/\/\1.archive.ubuntu.com\/ubuntu\//g' /etc/apt/sources.list
RUN apt-get update && apt-get install --assume-yes --no-install-recommends \
	autoconf \
	automake \
	bc \
	binutils \
	bison \
	kmod \
	libncurses-dev \
	libtool \
	libssl-dev \
	flex \
	m4 \
	make \
	pkg-config \
	gcc \
	libc6-dev \
	gcc-aarch64-linux-gnu \
	libc6-dev-arm64-cross

RUN dpkg --add-architecture arm64 && apt-get update

RUN apt-get install --assume-yes --no-install-recommends \
	libblkid-dev:arm64 \
	libssl-dev:arm64 \
	uuid-dev:arm64 \
	zlib1g-dev:arm64
	
ENV ARCH=arm64
ENV CROSS_COMPILE=aarch64-linux-gnu-
