

## config

```sh
this_cluster="movies-cluster"
this_region="us-east-1"

export AWS_ACC_ID=$(aws sts get-caller-identity --query Account --output text)


```


## create cluster

```sh
eksctl create cluster -f k8s/cluster-config.yaml
k config current-context

eksctl delete cluster --config-file=k8s/cluster-config.yaml
```


## PG

```sh
kubectl get csidrivers

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
  --service-account-role-arn arn:aws:iam::$AWS_ACC_ID:role/AmazonEKS_EBS_CSI_DriverRole \
  --force


```
