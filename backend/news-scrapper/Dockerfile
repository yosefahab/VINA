FROM python:3.11.8

WORKDIR /app

# copy source code
COPY *.py .
# copy news sources
COPY ./newspapers.txt .
COPY requirements.txt .

# install python dependencies
RUN pip install -r requirements.txt

CMD ["python", "main.py"]
