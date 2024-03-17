FROM mongo:latest

WORKDIR /app

COPY ./init.js ./schema.json /docker-entrypoint-initdb.d/

EXPOSE ${MONGO_PORT}
