import os
import logging
from threading import Event
import newspaper
from datetime import datetime
from article import Article
from concurrent.futures import ThreadPoolExecutor
from pipeline import Pipeline
from typing import List


class Scrapper:
    def __init__(self, pipeline: Pipeline, sources="newspapers.txt"):
        self.logger = logging.getLogger(__name__)
        self.newspapers_list = self.__import_sources(sources)
        self.pipeline = pipeline

    def __import_sources(self, file_path) -> List[str]:
        if not os.path.exists(file_path):
            self.logger.critical("Newspapers sources file not found.")
            return []
        with open(file_path, "r") as f:
            self.logger.info("Parsing newspapers sources file.")
            sources = [line.strip() for line in f.readlines()]
            self.logger.info("Found %d news sources", len(sources))
            return sources

    # scrape main sources and dispatch fetch function
    def start(self, event: Event):
        self.logger.info("scrapper started")
        # TODO: remove limit
        self.__scrape_sources(self.newspapers_list[0:30])
        self.logger.info(
            "finished scrapping with %d articles", self.pipeline.NEWS_BUFFER.qsize()
        )  # TODO: make it private
        event.set()

    # predefined news sources
    def __scrape_sources(self, sources: List[str]):
        with ThreadPoolExecutor(max_workers=4) as executor:
            executor.map(self.__scrape_article, sources)

    def __scrape_article(self, url: str):
        paper_source = newspaper.build(url, memoize_articles=True)
        self.logger.info("Scrapping: %s", url)

        articles: List[Article] = []
        for article in paper_source.articles:
            current_article = newspaper.Article(article.url)
            try:
                current_article.download()
                current_article.parse()
                if current_article.publish_date is None or (
                    current_article.publish_date is datetime
                    and current_article.publish_date.date() != datetime.today().date()
                ):  
                    continue

                current_article.nlp()

                articles.append(
                    Article.from_article(
                        current_article,
                        category="Science",  # TODO: detect category
                    )
                )
            except Exception as e:
                self.logger.error(
                    "Exception raised while prarsing article: %s", e, exc_info=1
                )

        else:
            # self.__push_to_buffer(articles)
            if len(articles) != 0:
                self.pipeline.put_many(articles)
