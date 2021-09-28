# MetaCall Golang TypeScript Python Http Example

This example shows how to embed TypeScript and Python into Go using MetaCall inside an HTTP server written in Go. In other words, calling TypeScript/Python functions from Go by using GET or POST. The instructions are focused on Linux but it can be ported to other platforms easily.

## Dependencies

For building this example you need NodeJS and Python to be installed in the system (12.x and 3.9 has been tested respectively). For debian based distros:

```bash
sudo apt-get install -y --no-install-recommends build-essential cmake ca-certificates git python3 python3-dev python3-pip nodejs npm unzip
```

Apart from this, you will need Go installed in order to build the main application. I have used Go 1.17.

## Build

Build MetaCall first, with NodeJS and TypeScript loaders enabled:

```bash
git clone --branch v0.5.4 https://github.com/metacall/core
mkdir core/build && cd core/build
cmake \
	-DNODEJS_CMAKE_DEBUG=On \
	-DOPTION_BUILD_LOADERS_PY=On \
	-DOPTION_BUILD_LOADERS_NODE=On \
	-DOPTION_BUILD_LOADERS_TS=On \
	-DOPTION_BUILD_PORTS=On \
	-DOPTION_BUILD_PORTS_PY=On \
	-DOPTION_BUILD_PORTS_NODE=On \
	-DOPTION_BUILD_DETOURS=Off \
	-DOPTION_BUILD_SCRIPTS=Off \
	-DOPTION_BUILD_TESTS=Off \
	-DOPTION_BUILD_EXAMPLES=Off \
	..
cmake --build . --target install
ldconfig /usr/local/lib
```

Now clone the Go/TypeScript/Python example and build it.

```sh
git clone https://github.com/metacall/golang-typescript-python-http-example.git
cd golang-typescript-python-http-example
go build main.go
```

## Run

From repository root directory, run the following commands:

```bash
export LOADER_LIBRARY_PATH="/usr/local/lib"
export LOADER_SCRIPT_PATH="`pwd`"
./main
```

## Testing

For testing the TypeScript endpoint:
```bash
curl localhost:8080/deploy_transaction_ts
# or repeated 1000 times:
for run in {1..1000}; do curl localhost:8080/deploy_transaction_ts; done
```

For testing the Python endpoint:
```bash
curl localhost:8080/deploy_transaction_py
# or repeated 1000 times:
for run in {1..1000}; do curl localhost:8080/deploy_transaction_py; done
```

For closing the server:
```bash
curl localhost:8080/close
```

## Docker

Building and running with Docker:

```bash
docker build -t metacall/golang-typescript-python-http-example .
docker run --rm -p 8080:8080 -it metacall/golang-typescript-python-http-example
```
