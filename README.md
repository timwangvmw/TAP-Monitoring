# [TAP]
## 1. Create an overlay
```
kubectl apply -f secret-tap-crd-overlay.yml -n tanzu-packages
```

## 2. Install the overlay
```
kubectl annotate PackageInstall prometheus ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=tap-crd-overlay -n tanzu-packages
```

## 3. Oberve the APP status
```
kubectl get app prometheus -n tanzu-packages
```

## 4. Apply ClusterRoleBinding
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus-kube-state-metrics-read-tap
subjects:
- kind: ServiceAccount
  namespace: tanzu-system-monitoring
  name: prometheus-kube-state-metrics
roleRef:
  kind: ClusterRole
  name: k8s-reader
  apiGroup: rbac.authorization.k8s.io
```
```
kubectl auth can-i list workload --as=system:serviceaccount:tanzu-system-monitoring:prometheus-kube-state-metrics
```

## 5. Test in Prometheus
kube_carto_run_v1alpha1_Workload_info
