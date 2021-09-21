#
#	MetaCall Golang Typescript Python HTTP Example by Parra Studios
#	An example of Golang with Typescript and Python with a HTTP server.
#
#	Copyright (C) 2016 - 2020 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#

FROM golang:1.17-bullseye

# Image descriptor
LABEL copyright.name="Vicente Eduardo Ferrer Garcia" \
	copyright.address="vic798@gmail.com" \
	maintainer.name="Vicente Eduardo Ferrer Garcia" \
	maintainer.address="vic798@gmail.com" \
	vendor="MetaCall Inc." \
	version="0.1"

# Install dependencies
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential \
		cmake \
		ca-certificates \
		git \
		python3 \
		python3-dev \
		python3-pip \
		nodejs \
		npm \
		unzip \
	&& npm install -g npm@latest

# Set working directory to home
WORKDIR /root

# Clone and build the project
RUN git clone --branch v0.5.6 https://github.com/metacall/core \
	&& mkdir core/build && cd core/build \
	&& cmake \
		-DNODEJS_CMAKE_DEBUG=On \
		-DOPTION_BUILD_LOADERS_PY=On \
		-DOPTION_BUILD_LOADERS_NODE=On \
		-DOPTION_BUILD_LOADERS_TS=On \
		-DOPTION_BUILD_PORTS=On \
		-DOPTION_BUILD_PORTS_PY=Off \
		-DOPTION_BUILD_PORTS_NODE=Off \
		-DOPTION_BUILD_DETOURS=Off \
		-DOPTION_BUILD_SCRIPTS=Off \
		-DOPTION_BUILD_TESTS=Off \
		-DOPTION_BUILD_EXAMPLES=Off \
		.. \
	&& cmake --build . --target install \
	&& ldconfig /usr/local/lib

# Copy scripts
COPY script.py script.ts package.json package-lock.json /home/scripts/

# Install NPM dependencies
RUN cd /home/scripts \
	&& npm install

# Set up enviroment variables
ENV LOADER_LIBRARY_PATH=/usr/local/lib \
	LOADER_SCRIPT_PATH=/home/scripts

# Copy source files
COPY main.go go.mod go.sum /root/

# Build the go source
RUN go build main.go

EXPOSE 8080

CMD [ "/root/main" ]
