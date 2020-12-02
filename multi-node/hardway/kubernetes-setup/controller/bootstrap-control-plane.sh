#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Installing Kubernetes binaries"
for _binary in kube-apiserver kube-controller-manager kube-scheduler; do
    wget -O /usr/local/bin/${_binary} -q https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/${_binary}
    chmod +x /usr/local/bin/${_binary}
done

mkdir -p /var/lib/kubernetes/

cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem \
    encryption-config.yaml /var/lib/kubernetes/

cat <<EOF >/etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://127.0.0.1:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config='api/all=true' \\
  --secure-port=6443 \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cp kube-controller-manager.kubeconfig /var/lib/kubernetes/

cat <<EOF >/etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --allocate-node-cidrs=true \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=10.244.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cp kube-scheduler.kubeconfig /var/lib/kubernetes/

mkdir -p /etc/kubernetes/config

cat <<EOF >/etc/kubernetes/config/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

cat <<EOF >/etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

write_info "Starting Kubernetes control plane services"
systemctl daemon-reload
systemctl enable kube-apiserver kube-controller-manager kube-scheduler
systemctl start kube-apiserver kube-controller-manager kube-scheduler

write_info "Waiting for control plane to respond"
_max_attempts=20
while :; do
    kubectl get componentstatus --kubeconfig admin.kubeconfig >/dev/null 2>&1 && break || sleep 2
    ((_iterations += 1))
    if [[ ${_iterations} -gt ${_max_attempts} ]]; then
        fail "Control plane did not respond after ${_max_attempts} attempts"
    fi
done

if [[ "$(kubectl get componentstatuses -o json | jq -r '.items[].conditions[].type' | uniq)" != "Healthy" ]]; then
    fail "One or more Kubernetes components are not healthy"
fi

for _service_name in kube-apiserver kube-controller-manager kube-scheduler; do
    write_info "Status of ${_service_name} service:"
    _service_status="$(systemctl status ${_service_name} | head -n18 2>&1)"
    _state="$(echo "${_service_status}" | grep '^[ ]*Active: ' | sed 's/.*(\(.*\)).*/\1/')"
    if [[ "${_state}" == "running" ]]; then
        write_info "     ${_service_name} is ${_state}"
    else
        fail "     ${_service_name} is ${_state}"
    fi
done

write_info "Adding Kubernetes RBAC policies"
kubectl apply -f /etc/setup/controller/k8s-resources/rbac.yaml

write_info "Installing flannel CNI"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# write_info "Installing calico CNI"
# kubectl apply -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
# kubectl apply -f https://docs.projectcalico.org/manifests/custom-resources.yaml

write_info "Installing CoreDNS"
kubectl apply -f /etc/setup/controller/k8s-resources/core_dns.yaml

write_info "Installing HAProxy Ingress Controller"
kubectl apply -f https://raw.githubusercontent.com/haproxytech/kubernetes-ingress/master/deploy/haproxy-ingress.yaml
