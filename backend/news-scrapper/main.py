import sys
sys.dont_write_bytecode = True
import logging

from scrapper import Scrapper
from pipeline import Pipeline
from database import Database

from dotenv import load_dotenv
from threading import Event
from concurrent.futures import ThreadPoolExecutor

def main():
    # load env variables for database
    load_dotenv(override=True, dotenv_path="../sql/.env")

    FORMAT = "[%(levelname)s] | [%(asctime)s] | In %(module)s: %(message)s\n"
    logging.basicConfig(format=FORMAT, filename="VINA.log", filemode="w", level=logging.INFO)

    _pipeline = Pipeline()
    event = Event()
    with ThreadPoolExecutor(max_workers=2) as executor:
        news_scrapper = Scrapper(_pipeline)
        db = Database(_pipeline)

        executor.submit(db.consume, event)
        executor.submit(news_scrapper.start, event)

if __name__ == "__main__":
    main()
