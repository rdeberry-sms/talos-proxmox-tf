resource "local_sensitive_file" "talosconfig" {
  content    = data.talos_client_configuration.cc.talos_config
  filename   = "${path.module}/talosconfig"
  depends_on = [talos_machine_bootstrap.bootstrap]
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "talosctl kubeconfig --force -n ${local.first_controlplane_ip} -e ${local.first_controlplane_ip} --talosconfig ${path.module}/talosconfig"
  }
  depends_on = [local_sensitive_file.talosconfig]
}

resource "null_resource" "kubeconfigapi" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ~/.kube/config config set clusters.${var.cluster_name}.server https://${var.kubernetes["ipv4_vip"]}:6443"
  }
  depends_on = [null_resource.kubeconfig]
}

resource "time_sleep" "wait_180_seconds" {
  depends_on = [null_resource.kubeconfig, null_resource.kubeconfigapi, vsphere_virtual_machine.nodes]

  create_duration = "180s"
}
