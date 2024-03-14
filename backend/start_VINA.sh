#!/bin/sh

echo "WIP DO NOT RUN!" ; exit 1


# start the database (Mongodb)
mongo start &
# check if it started correctly
mongo status &> /dev/null 
if [[ $? -eq 0 ]]; then
	echo "MySQL is ready."
else
	echo "Error: mongodb failed to start."
	exit 1 
fi

# start the scrapper
conda run -n VINA python ./article-scrapper/main.py &

# start the server
cargo run ./vina-backend-rs/src/main.rs &
# check actix web status
health_check_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/healthz)
if [[ $health_check_response -eq 200 ]]; then
  echo "Actix server is healthy."
else
  echo "Error! Actix server NOT healthy"
	kill -15 mongo 
	kill -15 vina-server-rs
	exit 1
fi

# Wait for all background processes to finish
wait

echo "All processes started!"
