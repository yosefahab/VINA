from dateutil import parser
import newspaper


class Article:
    def __init__(
        self,
        url: str,
        title: str,
        date: str,
        category: str,
        summary: str,
    ):
        self.title: str = title
        self.summary: str = summary
        self.url: str = url
        self.date: str = date
        self.category: str = category

    @classmethod
    def from_article(cls, article: newspaper.Article, category: str):
        article_date = None

        if article.publish_date is not None:
            if isinstance(article.publish_date, str):
                article_date = f"{parser.parse(article.publish_date):%d-%b-%Y}"
            else:
                article_date = f"{article.publish_date:%d-%b-%Y}"  # Assuming it's a datetime object
        else:
            article_date = "Not Specified"  # Temporary workaround

        return cls(
            title=article.title,
            url=article.url,
            date=article_date,
            category=category,
            summary=article.summary,
        )

    def __str__(self) -> str:
        return f"URL: {self.url}\nTitle: {self.title}\nDate: {self.date}\nCategory: {self.category}\nSummary: {self.summary}\n"
