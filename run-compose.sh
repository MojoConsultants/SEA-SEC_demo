#!/bin/bash
docker-compose up --build -d && docker-compose logs -f
#docker-compose up --build -d && docker-compose logs -f api 
#docker-compose up --build -d && docker-compose logs -f db
#docker-compose up --build -d && docker-compose logs -f web
