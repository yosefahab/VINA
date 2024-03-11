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
        try:
            db = Database(_pipeline)
        except Exception:
            exit(0)

        executor.submit(news_scrapper.start, event)
        executor.submit(db.consume, event)

    logging.info("Finished, exitting.")
if __name__ == "__main__":
    main()
