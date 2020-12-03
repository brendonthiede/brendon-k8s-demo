if ((Get-Command multipass -ErrorAction SilentlyContinue).Name -ne "multipass.exe") {
    Write-Host("Multipass needs to be installed before continuing. Install it and rerun this script.")
    Write-Host("    https://multipass.run/docs/installing-on-windows")
    exit
}

if ((Get-Command jq -ErrorAction SilentlyContinue).Name -ne "jq.exe") {
    Write-Host("jq needs to be installed as jq in your path before continuing. Install it and rerun this script.")
    Write-Host("    https://stedolan.github.io/jq/download/")
    exit
}

if (( multipass list --format json | jq -r '.list[] | select(.name == \"k8s-controller\") | .name') -eq "k8s-controller") {
    Write-Host("k8s-controller already exists. To reinstall, run the cluster-delete.ps1 script first.")
    exit
}

Write-Host "Launching VMs for the cluster." -ForegroundColor Green
foreach ($vm in ("k8s-controller", "node-1", "node-2")) {
    multipass launch --name $vm --cpus 2 --mem 2g --disk 20g
}

Write-Host "Generating SSH keys for use within the cluster." -ForegroundColor Green
multipass exec k8s-controller -- ssh-keygen -t RSA -b 4096 -C "intra-cluster shared key" -f "/home/ubuntu/.ssh/id_rsa" -q -N "''"

Write-Host "Staging files to be transfered to the cluster VMs." -ForegroundColor Green
$cwd = Split-Path $MyInvocation.MyCommand.Path
Remove-Item -Path $env:TEMP\archive -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path $env:TEMP\archive -ItemType Directory | Out-Null
Copy-Item -Path $cwd\.. -Destination $env:TEMP\archive -Recurse
Move-Item -Path $env:TEMP\archive\* $env:TEMP\archive\setup

Write-Host "Deleting unecessary folders from transfer staging area." -ForegroundColor Green
Remove-Item -Path $env:TEMP\archive\setup\.git -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $env:TEMP\archive\setup\.vscode -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $env:TEMP\archive\setup\.gitignore -Force -ErrorAction SilentlyContinue

Get-ChildItem $env:TEMP\archive\setup -Recurse | `
    Where-Object { $_.PSIsContainer -and $_.Name -eq "tmp" } | `
    ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force }

Get-ChildItem $env:TEMP\archive\setup -Recurse | `
    Where-Object { $_.PSIsContainer -and $_.Name -eq "node_modules" } | `
    ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force }

Write-Host "Copying cluster list and SSH keys for transfer to the cluster VMs." -ForegroundColor Green
multipass list --format json | jq '[.list[] | select(.name | test(\"k8s-controller|node-[12]\"))]' | Set-Content -Path $env:TEMP\archive\setup\vm-list.json -Force
multipass transfer k8s-controller:/home/ubuntu/.ssh/id_rsa $env:TEMP\archive\setup\id_rsa
multipass transfer k8s-controller:/home/ubuntu/.ssh/id_rsa.pub $env:TEMP\archive\setup\id_rsa.pub

Write-Host "Zipping files to transfer to cluster VMs." -ForegroundColor Green
Compress-Archive -Path $env:TEMP\archive\setup\* -DestinationPath $env:TEMP\archive\setup.zip -CompressionLevel NoCompression

Write-Host "Uploading core files to cluster VMs." -ForegroundColor Green
foreach ($vm in ("k8s-controller", "node-1", "node-2")) {
    multipass transfer $env:TEMP\archive\setup.zip $vm`:/tmp/setup.zip
    multipass transfer $cwd\scripts\stage-setup-files.sh $vm`:/tmp/stage-setup-files.sh
    multipass exec $vm -- sudo bash -c "sed -i 's/\r//g' /tmp/stage-setup-files.sh; chmod a+x /tmp/stage-setup-files.sh; /tmp/stage-setup-files.sh"
}

Write-Host "Initializing kubeadm on k8s-controller." -ForegroundColor Green
multipass exec k8s-controller -- sudo bash -c "cd /etc/setup/multipass/scripts/ && common/all.sh && controller/all.sh"

Write-Host "Pulling join-command and admin kube config from k8s-controller." -ForegroundColor Green
multipass transfer k8s-controller:/etc/setup/tmp/join-command.sh $env:TEMP/join-command.sh
New-Item -ItemType Directory -Force -Path $env:USERPROFILE/.kube | Out-Null
multipass transfer k8s-controller:/home/ubuntu/.kube/config $env:USERPROFILE/.kube/config

Write-Host "Joining workers to the cluster" -ForegroundColor Green
foreach ($vm in ("node-1", "node-2")) {
    multipass transfer $env:TEMP/join-command.sh $vm`:/tmp/join-command.sh
    multipass transfer $env:USERPROFILE/.kube/config $vm`:/tmp/admin.kubeconfig
    multipass exec $vm -- sudo bash -c "cd /etc/setup/multipass/scripts/ && common/all.sh && worker/all.sh"
}

Write-Host "Running post install steps on k8s-controller." -ForegroundColor Green
multipass exec k8s-controller -- sudo bash -c "cd /etc/setup/multipass/scripts/ && post-install/all.sh"
