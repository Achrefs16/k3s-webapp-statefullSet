#!/bin/bash
set -euo pipefail

K8S_DIR=~/lab5/k8s   # adjust if your folder differs
NAMESPACE=default    # change if using a namespace

echo "1) Apply ConfigMap & Secret"
kubectl apply -f "${K8S_DIR}/lab5-configmap.yaml"
kubectl apply -f "${K8S_DIR}/lab5-secret.yaml"

echo "2) Apply headless service (postgres-headless)"
kubectl apply -f "${K8S_DIR}/postgres-headless-service.yaml"

echo "3) Deploy StatefulSet (postgres)"
kubectl apply -f "${K8S_DIR}/postgres-statefulset.yaml"

echo "4) Apply regular DB service"
kubectl apply -f "${K8S_DIR}/postgres-service.yaml"

echo "5) Wait for postgres-0 to be ready (timeout 180s)"
kubectl wait --for=condition=ready pod -l app=postgres -n ${NAMESPACE} --timeout=180s || {
  echo "Timed out waiting for postgres pod readiness. Current pod status:"
  kubectl get pods -l app=postgres -o wide
  exit 1
}

echo "6) Show StatefulSet and PVCs"
kubectl get statefulset postgres
kubectl get pods -l app=postgres -o wide
kubectl get pvc -l app=postgres

echo "7) Deploy web app (unchanged Deployment + Service)"
kubectl apply -f "${K8S_DIR}/web-deployment.yaml"
kubectl apply -f "${K8S_DIR}/web-service.yaml"

echo "8) Wait for web deployment to be ready"
kubectl rollout status deployment/lab5-web --timeout=120s

echo "Deployment finished."
echo "StatefulSet pods:"
kubectl get pods -l app=postgres -o custom-columns=NAME:.metadata.name,IP:.status.podIP
echo "PVCs:"
kubectl get pvc -l app=postgres
