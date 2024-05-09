machine:
  nodeLabels:
    node.cloudprovider.kubernetes.io/platform: vmware
  certSANs:
    - ${apiDomain}
    - ${ipv4_vip}
    - ${ipv4_addr}
  kubelet:
    defaultRuntimeSeccompProfileEnabled: true # Enable container runtime default Seccomp profile.
    disableManifestsDirectory: true # The `disableManifestsDirectory` field configures the kubelet to get static pod manifests from the /etc/kubernetes/manifests directory.
    extraArgs:
      rotate-server-certificates: true
    clusterDNS:
      - ${cidrhost(split(",",serviceSubnets)[0], 10)}
  install:
    disk: /dev/sda
    image: factory.talos.dev/installer/d8b9e545cb5c9b359796f68defe5767696529d05c046306d35901a7807cd12ee:v1.7.1
    bootloader: true
    wipe: true
  network:
    hostname: "${hostname}"
    interfaces:
      - interface: eth0
        dhcp: false
        addresses:
          - ${ipv4_addr}/24
        routes:
          - network: 0.0.0.0/0
            gateway: ${gateway}
        vip:
          ip: ${ipv4_vip}
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
  allowSchedulingOnControlPlanes: false
  controlPlane:
    endpoint: https://${apiDomain}:6443
  network:
    dnsDomain: ${domain}
    podSubnets: ${format("%#v",split(",",podSubnets))}
    serviceSubnets: ${format("%#v",split(",",serviceSubnets))}
    cni:
      name: custom
      urls:
        - https://raw.githubusercontent.com/rdeberry-sms/talos-proxmox-tf/main/manifests/talos/cilium.yaml
        #- https://raw.githubusercontent.com/kubebn/talos-proxmox-kaas/main/manifests/talos/cilium.yaml
  proxy:
    disabled: true
  etcd:
    extraArgs:
      listen-metrics-urls: http://0.0.0.0:2381
  inlineManifests:
  - name: fluxcd
    contents: |-
      apiVersion: v1
      kind: Namespace
      metadata:
          name: flux-system
          labels:
            app.kubernetes.io/instance: flux-system
            app.kubernetes.io/part-of: flux
            pod-security.kubernetes.io/warn: restricted
            pod-security.kubernetes.io/warn-version: latest
  - name: cilium
    contents: |-
      apiVersion: v1
      kind: Namespace
      metadata:
          name: cilium
          labels:
            pod-security.kubernetes.io/enforce: "privileged"
  - name: external-dns
    contents: |-
      apiVersion: v1
      kind: Namespace
      metadata:
          name: external-dns
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
  - name: flux-system-secret
    contents: |-
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: github-creds
        namespace: flux-system
      data:
        identity: ${base64encode(identity)}
        identity.pub: ${base64encode(identitypub)}
        known_hosts: ${base64encode(knownhosts)}
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
  - name: flux-vars
    contents: |-
      apiVersion: v1
      kind: ConfigMap
      metadata:
        namespace: flux-system
        name: cluster-settings
      data:
        CACHE_REGISTRY: ${registry-endpoint}
        SIDERO_ENDPOINT: ${sidero-endpoint}
        CLUSTER_0_VIP: ${cluster-0-vip}
  externalCloudProvider:
    enabled: true
    manifests:
    - https://raw.githubusercontent.com/kubebn/talos-proxmox-kaas/main/manifests/talos/metallb-native.yaml
    - https://raw.githubusercontent.com/kubebn/talos-proxmox-kaas/main/manifests/talos/metrics-server.yaml
    - https://raw.githubusercontent.com/kubebn/talos-proxmox-kaas/main/manifests/talos/fluxcd.yaml
    - https://raw.githubusercontent.com/kubebn/talos-proxmox-kaas/main/manifests/talos/fluxcd-install.yaml
    - https://raw.githubusercontent.com/sergelogvinov/terraform-talos/main/_deployments/vars/talos-cloud-controller-manager-result.yaml
    #- https://raw.githubusercontent.com/sergelogvinov/proxmox-csi-plugin/main/docs/deploy/proxmox-csi-plugin-talos.yml
    #- https://raw.githubusercontent.com/sergelogvinov/proxmox-cloud-controller-manager/main/docs/deploy/cloud-controller-manager-talos.yml
    - https://github.com/prometheus-operator/prometheus-operator/raw/main/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
    - https://github.com/prometheus-operator/prometheus-operator/raw/main/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
    - https://github.com/prometheus-operator/prometheus-operator/raw/main/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
    - https://github.com/prometheus-operator/prometheus-operator/raw/main/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
    - https://github.com/prometheus-operator/prometheus-operator/raw/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
    - https://github.com/prometheus-operator/prometheus-operator/raw/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
    - https://github.com/prometheus-operator/prometheus-operator/raw/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
    - https://github.com/prometheus-operator/prometheus-operator/raw/main/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
    - https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml
    - https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
