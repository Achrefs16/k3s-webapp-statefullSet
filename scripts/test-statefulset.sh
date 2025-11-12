#!/bin/bash
set -euo pipefail

NAMESPACE=default
SS_NAME=postgres
WEB_SVC=lab5-web-service
DB_SVC=db-service

echo "1) Show current postgres pods and PVCs"
kubectl get pods -l app=postgres -o wide
kubectl get pvc -l app=postgres

echo
echo "2) Show DNS name for postgres-0 (headless)"
kubectl exec -it ${SS_NAME}-0 -- sh -c "hostname; echo; nslookup ${SS_NAME}-0.postgres-headless || true" || true

echo
echo "3) Insert a test row into DB (via postgres-0)"
DB_POD=${SS_NAME}-0
kubectl exec -it ${DB_POD} -- bash -lc "psql -U \$(printenv POSTGRES_USER || echo postgres) -d \$(printenv POSTGRES_DB || echo appdb) -c \"CREATE TABLE IF NOT EXISTS st_test (id SERIAL PRIMARY KEY, note TEXT); INSERT INTO st_test (note) VALUES ('before-delete'); SELECT * FROM st_test;\""

echo
echo "4) Delete postgres-0 and observe that its name is recreated with same identity (pod will be recreated by StatefulSet)"
kubectl delete pod ${DB_POD}
echo "Waiting for ${DB_POD} to be recreated and ready..."
kubectl wait --for=condition=ready pod/${DB_POD} --timeout=180s

echo
echo "5) Verify the data still exists after recreation"
kubectl exec -it ${DB_POD} -- bash -lc "psql -U \$(printenv POSTGRES_USER || echo postgres) -d \$(printenv POSTGRES_DB || echo appdb) -c 'SELECT * FROM st_test;'"

echo
echo "6) Show PVC list (should still exist and be bound)"
kubectl get pvc -l app=postgres

echo
echo "7) Scale to 2 replicas and show sequential creation"
kubectl scale statefulset ${SS_NAME} --replicas=2
echo "Waiting for postgres-1 to appear"
kubectl wait --for=condition=ready pod/${SS_NAME}-1 --timeout=180s
kubectl get pods -l app=postgres -o wide
kubectl get pvc -l app=postgres

echo
echo "8) Clean up: (optional) scale back to 1"
echo "If you want to leave the StatefulSet scaled up, skip the next command."
# kubectl scale statefulset ${SS_NAME} --replicas=1

echo "TESTS complete."
