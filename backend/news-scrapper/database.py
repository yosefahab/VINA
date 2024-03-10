import logging
from threading import Event
import pymongo
import os
from article import Article
from pipeline import Pipeline

class Database():
    def __init__(self, pipeline: Pipeline):
        self.logger = logging.getLogger(__name__)
        self.pipeline = pipeline
        try:
            username = os.environ["MONGO_USERNAME"]
            password = os.environ["MONGO_PASSWORD"]

            client = pymongo.MongoClient("mongodb://{}:{}@localhost:27017".format(username, password))
            self.database = client["news"]
            self.articles = self.database["articles"]
            self.breaking_news = self.database["articles"]
        except Exception as e:
            self.logger.critical("Failed to initialize mongodb: %s", e, exc_info=True)

    def __add_breaking_news(self, article: Article):
        self.breaking_news.insert_one(article.toJson())
        self.logger.info("Inserted one breaking news into db")

    def __add_article(self, article: Article):
        self.articles.insert_one(article.toJson())
        self.logger.info("Inserted one article into db")

    def consume(self, event: Event):
        while True:
            article = self.pipeline.get_one()
            if article is not None:
                self.logger.info("DB got article: %s", article.__str__())

            if event.is_set():
                break
