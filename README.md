# react-flask-pg-eks

## run dev mode

```sh
#chmod +x build-and-run.sh
#./build-and-run.sh

API_HOST=http://3.95.55.160:5000 docker-compose up --build

```

## config
```
this_cluster="movies-cluster"
this_region="us-east-1"
export AWS_ACC_ID=$(aws sts get-caller-identity --query Account --output text)


```


## ECR
```sh

# authenticate/login to ecr
aws ecr get-login-password --region us-east-1 | \
docker login \
  --username AWS \
  --password-stdin \
  $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com


# backend:
this_repoName="frontend"
output=$(aws ecr create-repository --repository-name $this_repoName --region $this_region)
repo_uri=$(echo "$output" | jq -r '.repository.repositoryUri')
account_id=$(echo "$output" | jq -r '.repository.registryId')

echo "Repository URI: $repo_uri"
echo "Account ID: $account_id"

# tag & push backend image
docker build -t backend ./backend
docker build -t frontend ./frontend

IMG_TAG=v1

echo "Repository URI: $repo_uri"
echo "Account ID: $account_id"

docker tag backend:latest ${repo_uri}:${IMG_TAG}
docker push ${repo_uri}:${IMG_TAG}
```
