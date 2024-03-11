import os
import logging
from threading import Event
import pymongo
from article import Article
from pipeline import Pipeline


class Database:
    def __init__(self, pipeline: Pipeline):
        self.logger = logging.getLogger(__name__)
        self.pipeline = pipeline
        try:
            username = os.environ["MONGO_USERNAME"]
            password = os.environ["MONGO_PASSWORD"]

            client = pymongo.MongoClient(
                "mongodb://{}:{}@localhost:27017".format(username, password),
                connect=True,
            )
            self.database = client["news"]
            self.articles = self.database["articles"]
            self.breaking_news = self.database["breaking_news"]
        except Exception as e:
            self.logger.critical("Failed to initialize MongoDB: %s", e, exc_info=True)
            raise
        self.logger.info("Successfully initialized MongoDB")

    def __add_one_breaking_news(self, article: Article):
        self.breaking_news.insert_one(article.__dict__)
        self.logger.info("Inserted one breaking news into db")

    def __add_one_article(self, article: Article):
        # self.articles.insert_one(article.__dict__)
        # ?update makes sure duplicates aren't inserted.
        # ?this is a temporary workaround
        self.articles.update_one(
            {"url": article.url}, {"$set": article.__dict__}, upsert=True
        )
        self.logger.info("Inserted one article into db")

    def consume(self, event: Event):
        stop = False
        while not stop or len(self.pipeline.NEWS_BUFFER.queue) != 0:
            article = self.pipeline.get_one()
            if article is not None:
                self.__add_one_article(article)

            stop = event.is_set()


if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv(override=True, dotenv_path="../sql/.env")
    e = Event()
    p = Pipeline()
    p.put_one(
        Article("url", "title", "date", "category", "summary"),
    )
    db = Database(p)
    e.set()
    db.consume(e)
