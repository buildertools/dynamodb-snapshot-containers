FROM openjdk:8-jre
EXPOSE 8000
RUN mkdir -p /var/dynamodb
COPY dynamodb_local_latest /usr/local/dynamodb
WORKDIR /usr/local/dynamodb
CMD java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -dbPath /var/dynamodb/
