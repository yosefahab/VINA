from datetime import date
import json
import newspaper


class Article:
    def __init__(
        self,
        title: str,
        url: str,
        summary: str,
        date: date,
        category: str,
    ):
        self.title = title
        self.summary = summary
        self.url = url
        self.date = f"{date:%d-%b-%Y}"
        self.category = category

    @classmethod
    def from_article(cls, article: newspaper.Article, category: str):
        return cls(
            title=article.title,
            url=article.url,
            summary=article.summary,
            date=article.publish_date,
            category=category,
        )

    def toJson(self):
        return json.dumps(self.__dict__)

    def __str__(self):
        return f"Title: {self.title}\nURL: {self.url}\nDate: {self.date}\nCategory: {self.category}\nSummary: {self.summary}\n"
