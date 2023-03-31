# flutter-docker

## Usage

```bash
# clone this repository
git clone https://github.com/pedrox-hs/flutter-docker.git
cd flutter-docker

# build image
docker build -t flutter_sdk:latest .

# usage example
docker run -ti --rm -v $PWD/example:/home/devel/apps/example:Z flutter_sdk:latest bash -c 'cd /home/devel/apps/example && flutter build apk'
```