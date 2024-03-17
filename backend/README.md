# Backend
Following are the modules that make up the backend for VINA.

## news-scrapper
Collects news from around the internet, especially from predefined list of trusted sources (newspapers.txt).

## Database
The database used to store articles for all backend microservices (MongoDB).

### Summarization
Currently relying on newspaper3k's `nlp()` and `summary()` functions. But plan is to use more sophisticated Deep Learning methods.

## vina-server
serves the articles to the frontend via a rust actix-web http server.
