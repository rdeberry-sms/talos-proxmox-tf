machine:
  nodeLabels:
    node.cloudprovider.kubernetes.io/platform: vmware
  kubelet:
    defaultRuntimeSeccompProfileEnabled: true # Enable container runtime default Seccomp profile.
    disableManifestsDirectory: true # The `disableManifestsDirectory` field configures the kubelet to get static pod manifests from the /etc/kubernetes/manifests directory.
    extraArgs:
      cloud-provider: external
      rotate-server-certificates: true
      node-labels: "project.io/node-pool=worker"
    clusterDNS:
      - ${cidrhost(split(",",serviceSubnets)[0], 10)}
  install:
    disk: /dev/sda
    image: factory.talos.dev/installer/d8b9e545cb5c9b359796f68defe5767696529d05c046306d35901a7807cd12ee:v1.7.1
    bootloader: true
    wipe: false
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
    extraHostEntries:
      - ip: ${ipv4_vip}
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
  proxy:
    disabled: true
