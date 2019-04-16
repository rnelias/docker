FROM alpine:3.6
# In case the main package repositories are down, use the alternative base image:
# FROM gliderlabs/alpine:3.4

MAINTAINER Renato Elias <rnelias@gmail.com>

RUN apk update && apk upgrade \
      && apk add --no-cache build-base \
      && apk add --no-cache gfortran \
      && apk add --no-cache git \
      && apk add --no-cache bash \
      && apk add --no-cache cmake

#RUN apk add --no-cache gfortran gdb make

#### INSTALL MPICH ####
# Source is available at http://www.mpich.org/static/downloads/

# Build Options:
# See installation guide of target MPICH version
# Ex: http://www.mpich.org/static/downloads/3.2/mpich-3.2-installguide.pdf
# These options are passed to the steps below
ARG MPICH_VERSION="3.2"
ARG MPICH_CONFIGURE_OPTIONS="--enable-fortran"
ARG MPICH_MAKE_OPTIONS

# Download, build, and install MPICH
RUN mkdir /tmp/mpich-src
WORKDIR /tmp/mpich-src
RUN wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz \
      && tar xfz mpich-${MPICH_VERSION}.tar.gz  \
      && cd mpich-${MPICH_VERSION}  \
      && ./configure ${MPICH_CONFIGURE_OPTIONS}  \
      && make ${MPICH_MAKE_OPTIONS} && make install \
      && rm -rf /tmp/mpich-src


#### download and compile gmsh ####
ARG GMSH_VERSION="4.2.3"
RUN mkdir /tmp/gmsh-build
WORKDIR  /tmp/gmsh-build
RUN wget http://gmsh.info/src/gmsh-${GMSH_VERSION}-source.tgz \
      && tar xvfz gmsh-${GMSH_VERSION}-source.tgz \
      && cmake /tmp/gmsh-build/gmsh-${GMSH_VERSION}-source \
      && make && make install \
      && rm -rf /tmp/gmsh-build

#### CLEAN UP ####
WORKDIR /
RUN rm -rf /tmp/*

#### ADD DEFAULT USER ####
ARG USER=mpi
ENV USER ${USER}
RUN adduser -D ${USER} \
      && echo "${USER}   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV USER_HOME /home/${USER}
RUN chown -R ${USER}:${USER} ${USER_HOME}

#### CREATE WORKING DIRECTORY FOR USER ####
ARG WORKDIR=/project
ENV WORKDIR ${WORKDIR}
RUN mkdir ${WORKDIR}
RUN chown -R ${USER}:${USER} ${WORKDIR}

WORKDIR ${WORKDIR}
USER ${USER}


CMD ["/bin/ash"]
