from newspaper import logging
from article import Article
from queue import Queue
from typing import List

class Pipeline():
    def __init__(self) -> None:
        self.logger = logging.getLogger(__name__)
        BUFFER_CAPACITY: int = 100
        self.NEWS_BUFFER: Queue[Article] = Queue(maxsize=BUFFER_CAPACITY)

    def get_one(self) -> Article | None:
        try:
            return self.NEWS_BUFFER.get(timeout=0.1)
        except Exception:
            self.logger.debug("NEWS_BUFFER empty")
            return None
    
    def put_one(self, article: Article) -> None:
        self.NEWS_BUFFER.put(article)

    def put_many(self, articles: List[Article]) -> None:
        for article in articles:
            self.NEWS_BUFFER.put(article)
        self.logger.info("Pipeline received %s articles", len(articles))
