
# investigate the docker container
```sh
docker compose run --rm backend sh

docker exec -it react-flask-pg-eks-backend-1 sh

```


# wait-for-it.sh
```sh
# run `chmod +x backend/wait-for-it.sh` on local machine
# and then build container.

```


# ping backend api
```sh
curl -X POST http://localhost:5000/rate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice",
    "series_name": "Breaking Bad",
    "rating": 5
  }'


curl http://localhost:5000/recent



curl http://localhost:5000/stats/Breaking%20Bad



```
