#!/bin/bash
# Check if all services are running
curl -f http://localhost:3001/health >/dev/null 2>&1 && \
curl -f http://localhost:3000 >/dev/null 2>&1 && \
nc -z localhost 22 && \
nc -z localhost 5432