# ==============================
# Lab 5 Deployment Automation (Windows)
# ==============================

# --- CONFIGURATION ---
$projectPath = "C:\Users\achra\Desktop\devops 2\administration d'une platforme de conteneurs\lab5\app"
$imageName = "achrefs161/lab5-nextjs:latest"
$vmUser = "achref"
$vmIP = "192.168.50.10"
$vmK8sFolder = "/home/achref/lab5/k8s"

# --- BUILD AND PUSH DOCKER IMAGE ---
Write-Host "=== Building Docker image ==="
cd "$projectPath\app"

# Make sure Docker Desktop is running
docker build -t $imageName .
docker push $imageName

# --- COPY K8S YAML FILES TO VM ---
Write-Host "=== Copying YAML files to K3s VM ==="
ssh "$vmUser@$vmIP" "mkdir -p $vmK8sFolder"
scp "$projectPath\k8s\*.yaml" "$($vmUser)@$($vmIP):$($vmK8sFolder)"

# --- APPLY KUBERNETES MANIFESTS ---
Write-Host "=== Applying Kubernetes manifests ==="
ssh "$vmUser@$vmIP" "sudo kubectl apply -f $vmK8sFolder"

# --- WAIT FOR DATABASE POD TO BE READY ---
Write-Host "=== Waiting for DB pod to be ready ==="
ssh "$vmUser@$vmIP" "sudo kubectl wait --for=condition=ready pod -l app=lab5-db --timeout=60s"

# --- CREATE 'users' TABLE IN POSTGRES ---
Write-Host "=== Creating 'users' table in PostgreSQL ==="
$podName = ssh "$vmUser@$vmIP" "sudo kubectl get pods -l app=lab5-db -o jsonpath='{.items[0].metadata.name}'"
ssh "$vmUser@$vmIP" "sudo kubectl exec -i $podName -- psql -U postgres -d appdb -c `"CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(100), email VARCHAR(150) UNIQUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);`""

# --- DEPLOYMENT COMPLETE ---
Write-Host "=== Deployment complete! ==="
Write-Host "Access app at http://$vmIP:30080"
