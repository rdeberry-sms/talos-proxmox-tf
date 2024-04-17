machine:
  nodeLabels:
    node.cloudprovider.kubernetes.io/platform: proxmox
    topology.kubernetes.io/region: ${px_region}
    topology.kubernetes.io/zone: ${px_node}
  certSANs:
    - ${apiDomain}
    - ${ipv4_vip}
    - ${ipv4_local}
  kubelet:
    defaultRuntimeSeccompProfileEnabled: true # Enable container runtime default Seccomp profile.
    disableManifestsDirectory: true # The `disableManifestsDirectory` field configures the kubelet to get static pod manifests from the /etc/kubernetes/manifests directory.
    extraArgs:
      rotate-server-certificates: true
    clusterDNS:
      - 169.254.2.53
      - ${cidrhost(split(",",serviceSubnets)[0], 10)}
  network:
    hostname: "${hostname}"
    interfaces:
      - interface: eth0
        addresses:
          - ${ipv4_local}/24
        vip:
          ip: ${ipv4_vip}
      - interface: dummy0
        addresses:
          - 169.254.2.53/32
    extraHostEntries:
      - ip: 127.0.0.1
        aliases:
          - ${apiDomain}
    nameservers:
      - ${nameserver}
    kubespan:
      enabled: false
  time:
    servers:
      - ${ntpserver}
  sysctls:
    net.core.somaxconn: 65535
    net.core.netdev_max_backlog: 4096
  systemDiskEncryption:
    state:
      provider: luks2
      options:
        - no_read_workqueue
        - no_write_workqueue
      keys:
        - nodeID: {}
          slot: 0
    ephemeral:
      provider: luks2
      options:
        - no_read_workqueue
        - no_write_workqueue
      keys:
        - nodeID: {}
          slot: 0
  # Features describe individual Talos features that can be switched on or off.
  features:
    rbac: true # Enable role-based access control (RBAC).
    stableHostname: true # Enable stable default hostname.
    apidCheckExtKeyUsage: true # Enable checks for extended key usage of client certificates in apid.
    kubernetesTalosAPIAccess:
      enabled: true
      allowedRoles:
        - os:reader
      allowedKubernetesNamespaces:
        - kube-system
  kernel:
    modules:
      - name: br_netfilter
        parameters:
          - nf_conntrack_max=131072
cluster:
  controlPlane:
    endpoint: https://${apiDomain}:6443
  network:
    dnsDomain: ${domain}
    podSubnets: ${format("%#v",split(",",podSubnets))}
    serviceSubnets: ${format("%#v",split(",",serviceSubnets))}
    cni:
      name: custom
      urls:
        - https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/canal.yaml
  proxy:
    disabled: true
  etcd:
    extraArgs:
      listen-metrics-urls: http://0.0.0.0:2381
  inlineManifests:
  - name: cert-manager
    contents: |-
      apiVersion: v1
      kind: Namespace
      metadata:
          name: cert-manager
  - name: ingress-nginx
    contents: |-
      apiVersion: v1
      kind: Namespace
      metadata:
          name: ingress-nginx
  - name: proxmox-cloud-controller-manager
    contents: |-
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: proxmox-cloud-controller-manager
        namespace: kube-system
      data:
        config.yaml: ${base64encode(clusters)}
  - name: proxmox-csi-plugin
    contents: |-
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: proxmox-csi-plugin
        namespace: csi-proxmox
      data:
        config.yaml: ${base64encode(clusters)}
  - name: proxmox-operator-creds
    contents: |-
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: proxmox-operator-creds
        namespace: kube-system
      data:
        config.yaml: ${base64encode(pxcreds)}
  - name: metallb-addresspool
    contents: |-
      apiVersion: metallb.io/v1beta1
      kind: IPAddressPool
      metadata:
        name: first-pool
        namespace: metallb-system
      spec:
        addresses:
        - ${metallb_l2_addressrange}
  - name: metallb-l2
    contents: |-
      apiVersion: metallb.io/v1beta1
      kind: L2Advertisement
      metadata:
        name: layer2
        namespace: metallb-system
      spec:
        ipAddressPools:
        - first-pool
  externalCloudProvider:
    enabled: true
    manifests:
    - https://raw.githubusercontent.com/metallb/metallb/v0.14.4/config/manifests/metallb-native.yaml
    - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    - https://raw.githubusercontent.com/kubebn/talos-proxmox-kaas/main/manifests/talos/fluxcd.yaml
    - https://raw.githubusercontent.com/kubebn/talos-proxmox-kaas/main/manifests/talos/fluxcd-install.yaml
    - https://raw.githubusercontent.com/sergelogvinov/terraform-talos/main/_deployments/vars/talos-cloud-controller-manager-result.yaml
    - https://raw.githubusercontent.com/sergelogvinov/proxmox-cloud-controller-manager/main/docs/deploy/cloud-controller-manager-talos.yml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.64.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.64.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.64.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.64.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.64.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.64.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.64.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.64.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
