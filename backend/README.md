# Backend
Following are the modules that make up the backend for VINA.

## news-scrapper
Collects news from around the internet, especially from predefined list of trusted sources (newspapers.txt).

## Database
The database used to store articles for all backend microservices (MongoDB).

### Summarization
Currently relying on newspaper3k's `nlp()` and `summary()` functions. But plan is to use more sophisticated Deep Learning methods.

## vina-server
Serves the articles to the frontend via a rust actix-web http server.
Currently clients can request data using **Short Polling**, but plans to implement **Long Polling** in the future.

## How to start
### Using docker
create a .env file in the root of the project (this directory), and add the following environment variables:
```shell
MONGO_USERNAME="your username"
MONGO_PASSWORD="a password"
MONGO_HOSTNAME="vina-db" # don't change this
MONGO_PORT=27017 # don't change this (or do if you know what you're doing)
MONGO_DB="news" # don't change this
VINA_PORT=8080 # don't change this (or do if you know what you're doing)
```

These variables are used all around the project, the username and password are used in the creation of the database, which is done automatically in ./database/init.js
