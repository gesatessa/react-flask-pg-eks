
# config
```sh
this_cluster="movies-cluster"
this_region="us-east-1"
export AWS_ACC_ID=$(aws sts get-caller-identity --query Account --output text)
```


# cluster
```sh
eksctl create cluster -f ./k8s/cluster-config.yaml


# delete
eksctl delete cluster --config-file=k8s/cluster-config.yaml
```


# ECR
```sh
# authenticate

aws ecr get-login-password --region us-east-1 | \
docker login \
  --username AWS \
  --password-stdin \
  $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com


# build, tag, push to ECR
this_repoName="frontend" # "frontend" & "backend"
output=$(aws ecr create-repository --repository-name $this_repoName --region $this_region)
repo_uri=$(echo "$output" | jq -r '.repository.repositoryUri')

echo "Repository URI: $repo_uri"

# tag & push backend image
docker build -t frontend ./frontend
# docker run -it --rm frontend:latest sh

IMG_TAG=v3
docker tag frontend:latest ${repo_uri}:${IMG_TAG}
docker push ${repo_uri}:${IMG_TAG}

```


## verify images
```sh
# ECR image was updated, but Kubernetes is using an old cached image
# imagePullPolicy: Always
kubectl run temp-debug --rm -i -t \
  --image=${repo_uri}:${IMG_TAG} \
  -- /bin/sh
kubectl rollout restart deployment frontend


# example 
docker pull 018733487945.dkr.ecr.us-east-1.amazonaws.com/frontend:v2
docker run -it --rm 018733487945.dkr.ecr.us-east-1.amazonaws.com/frontend:v1 sh

```


# OICD provider
```sh
eksctl utils associate-iam-oidc-provider \
  --region=$this_region \
  --cluster=$this_cluster \
  --approve

```

# EBS CSI driver
```sh
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster $this_cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-name AmazonEKS_EBS_CSI_DriverRole


eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster $this_cluster \
  --region $this_region \
  --service-account-role-arn arn:aws:iam::$AWS_ACC_ID:role/AmazonEKS_EBS_CSI_DriverRole \
  --force


k get csidriver # ebs.csi.aws.com

k apply -f gp3-storageclass.yaml # gp3
```


# Postgres
```sh
k apply -f pg-pvc.yaml # bound; k get pvc, pv
k apply -f pg-secret.yaml
k apply -f pg-deploy-svc.yaml # status: running; & ready


```


# backend

```sh
k apply -f backend-secret.yaml
k apply -f backend-deploy-svc.yaml

cd backend # wait-for-it.sh is located
kubectl create configmap backend-wait-script \
  --from-file=wait-for-it.sh



# check if backend api is reachable:
kubectl patch svc backend -p '{"spec": {"type": "NodePort"}}'
#http://<Node_IP>:<NodePort>

# curl -i http://54.226.43.83:31984/recent
```


## backend api

```sh
curl -X POST http://54.226.43.83:31984/rate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Kim",
    "series_name": "Breaking Bad",
    "rating": 3
  }'


curl -i http://54.226.43.83:31984/recent

```


# frontend
```sh
k apply -f frontend-configmap.yaml
k apply -f frontend-deploy-svc.yaml
```


# ingress controller
```sh
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json

aws iam create-policy \
  --policy-name AWSLBControllerIAMPolicy \
  --policy-document file://iam_policy.json

# associate IAM OIDC Provider with the Cluster
# we've done this already before
eksctl utils associate-iam-oidc-provider \
  --region $this_region \
  --cluster $this_cluster \
  --approve


eksctl create iamserviceaccount \
  --cluster $this_cluster \
  --namespace kube-system \
  --name aws-lb-ctl \
  --role-name AWSEKSLBControllerRole \
  --attach-policy-arn arn:aws:iam::$AWS_ACC_ID:policy/AWSLBControllerIAMPolicy \
  --approve


## ================================= #
# install AWS ALB controller via Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

this_vpc=$(aws eks describe-cluster \
  --name "$this_cluster" \
  --region "$this_region" \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text)
echo $this_vpc

helm install aws-lb-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$this_cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-lb-ctl \
  --set region=$this_region \
  --set vpcId=$this_vpc



```

# ingress

```sh
k apply -f ingress.yaml

# wait a couple of minutes till the ALB is provisioned and becomes active
# now you can get the "public IP" of the assigned DNS to the ALB:
nslookup k8s-default-frontend-ecfa3a496a-478488426.us-east-1.elb.amazonaws.com

# in `ingress.yaml`, change the host to 
# host: <ALB_PUBLIC_IP>.nip.io

k apply -f ingress.yaml
```

# 
