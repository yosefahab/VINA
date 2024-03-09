#!/bin/sh

echo "WIP DO NOT RUN!" ; exit 1


# start the database (Mongodb)
service mongo start &
service mongo status &> /dev/null # check if it started correctly
if [[ $? -eq 0 ]]; then
	echo "MySQL is ready."
else
	echo "Error: mongodb failed to start."
	exit 1 
fi

# start the scrapper
service conda run -n VINA python ./article-scrapper/main.py &
service cargo run ./vina-backend-rs/src/main.rs &
# check actix web status
# opt1 check for port
if [[ $(netstat -tlpn | grep ":8080") ]]; then
  echo "Actix server port is open (might be ready)."
else
  echo "Error! Actix server failed to start."
	kill -15 mongo 
	exit 1
fi

# opt2 send a GET request to the health check endpoint
health_check_response=$(curl -s http://localhost:8080/healthz)
if [[ $health_check_response == "{\"status\": \"healthy\"}" ]]; then
  echo "Actix server is healthy."
else
  echo "Error! Actix server NOT healthy"
	kill -15 mongo 
	kill -15 vina-server-rs
	exit 1
fi

# Wait for all background processes to finish (optional)
wait

echo "All processes started!"
