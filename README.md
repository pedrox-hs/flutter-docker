# flutter-docker

## Build

```bash
# clone this repository
git clone https://github.com/pedrox-hs/flutter-docker.git
cd flutter-docker

# build image
docker build -t flutter_sdk:latest .
```

## Usage

There is an usage example:

```bash
docker run -ti --rm -v $PWD/example:/home/devel/apps/example:Z -w /home/devel/apps/example flutter_sdk:latest flutter build apk
```