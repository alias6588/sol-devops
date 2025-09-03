docker exec -it $(docker ps --filter name=sol_back -q) alembic -c /app/alembic.ini upgrade head
