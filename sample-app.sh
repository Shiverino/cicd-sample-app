#!/bin/bash
set -euo pipefail

#mkdir tempdir 2>/dev/null
#mkdir tempdir/templates 2>/dev/null
#mkdir tempdir/static 2>/dev/null

cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

cat > tempdir/Dockerfile << _EOF_
FROM python
RUN pip install flask
COPY  ./static /home/myapp/static/
COPY  ./templates /home/myapp/templates/
COPY  sample_app.py /home/myapp/
EXPOSE 5050
CMD python /home/myapp/sample_app.py
_EOF_

cd tempdir || exit
docker build -t sampleapp .

container_name="samplerunning"

# Controleer of de container bestaat
if docker ps -a --format '{{.Names}}' | grep -Eq "^$container_name$"; then
    # Verwijder de container als deze bestaat
    docker rm -f "$container_name"
    echo "Container $container_name is verwijderd."
else
    echo "Container $container_name bestaat niet."
fi

docker run -t -d -p 5050:5050 --name samplerunning sampleapp
docker ps -a 
