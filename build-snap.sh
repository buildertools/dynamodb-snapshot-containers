#!/bin/sh

helpText () {
  echo "build-snap.sh SCRIPT_FILENAME OUTPUT_REPOSITORY [AUTHOR] {MESSAGE}"
}

if [ "$#" -lt 2 ]
then
	helpText
	exit 1
fi

if [ "$#" -gt 4 ]
then
	helpText
	exit 1
fi

if [ ! -f $1 ]
then
	echo No such input script
	exit 1
fi

CID=$(docker run -d buildertools/dynamodb-local)
BID=$(docker run -d -v "$(pwd)"/"$1":/usr/local/db-script/"$1" --net container:$CID buildertools/dynamodb-snap-builder ./"$1")
docker wait $BID > /dev/null
echo "Build complete using: $1"
docker stop $CID > /dev/null
echo Committing to repository: $2
ID=$(docker commit -a "$3" -m "$4" $CID $2)
echo Cleaning up...
docker rm -v $CID $BID > /dev/null
echo Done: $ID
