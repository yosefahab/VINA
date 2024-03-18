FROM python:3.11.8

WORKDIR /app

COPY requirements.txt .
# install python dependencies
RUN pip install -r requirements.txt

# copy news sources
COPY ./newspapers.txt .
# copy source code
COPY *.py .

CMD ["python", "main.py"]
