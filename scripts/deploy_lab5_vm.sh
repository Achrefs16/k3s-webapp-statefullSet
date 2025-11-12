#!/bin/bash
# ==============================
# Lab 5 Deployment Automation (VM)
# ==============================

# --- CONFIGURATION ---
PROJECT_DIR=~/lab5/app
DOCKER_PATH="$PROJECT_DIR/app"   # actual app code
IMAGE_NAME=achrefs161/lab5-nextjs:latest
K8S_DIR="$PROJECT_DIR/k8s"

echo "=== Building Docker image ==="
cd "$DOCKER_PATH"
docker build -t $IMAGE_NAME .

echo "=== Pushing image to Docker Hub ==="
docker push $IMAGE_NAME

echo "=== Applying Kubernetes manifests ==="
kubectl apply -f "$K8S_DIR"

echo "=== Waiting for database to start... ==="
sleep 10

echo "=== Creating 'users' table in PostgreSQL ==="
DB_POD=$(kubectl get pods -l app=lab5-db -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $DB_POD -- psql -U postgres -d appdb -c "CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(100), email VARCHAR(150) UNIQUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

echo "=== Deployment complete! ==="
echo "App URL: http://$(hostname -I | awk '{print $1}'):30080"
