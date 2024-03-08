import sys
sys.dont_write_bytecode = True
import logging

from scrapper import Scrapper
from pipeline import Pipeline
from database import Database

from threading import Event, Thread
from concurrent.futures import ThreadPoolExecutor

import json
from datetime import datetime
from article import Article

def main():
    FORMAT = "[%(levelname)s] | [%(asctime)s] | In %(module)s: %(message)s\n"
    logging.basicConfig(format=FORMAT, filename="VINA.log", filemode="w", level=logging.INFO)

    _pipeline = Pipeline()
    event = Event()
    with ThreadPoolExecutor(max_workers=2) as executor:
        article_scrapper = Scrapper(_pipeline)
        db = Database(_pipeline)

        executor.submit(article_scrapper.start, event)
        executor.submit(db.consume, event)

    # a = Article("", "", "", datetime.today().__str__(), "")
    # print(a)
    # print(a.toJson())
    # _pipeline.NEWS_BUFFER.put(a)
    #
    if len(_pipeline.NEWS_BUFFER.queue) != 0:
        with open("news.json", "w") as jfile:
            l = [a.toJson() for a in _pipeline.NEWS_BUFFER.queue]
            json.dump(l, jfile)

if __name__ == "__main__":
    main()
