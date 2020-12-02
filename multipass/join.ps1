foreach ($vm in ("node-1", "node-2")) {
    multipass transfer k8s-controller:/etc/setup/tmp/join-command.sh $env:TEMP/join-command.sh
    multipass transfer $env:TEMP/join-command.sh $vm`:/tmp/join-command.sh
    multipass transfer k8s-controller:/home/ubuntu/.kube/config $env:TEMP/admin.kubeconfig
    multipass transfer $env:TEMP/admin.kubeconfig $vm`:/tmp/admin.kubeconfig
    multipass exec $vm -- sudo bash -c "cd /etc/setup/multipass/scripts/ && common/all.sh && worker/all.sh"
}
