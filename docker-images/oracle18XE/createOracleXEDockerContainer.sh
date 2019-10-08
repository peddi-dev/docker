#!/bin/bash
docker run -it -p 1521:1521 -p 5500:5500 -h devXE --name devXE oracle-db:18cXE
