{ ... }:
let
  genFile = name: set: builtins.toFile "${name}.json" (builtins.toJSON set);

  psaConf = {
    apiVersion = "apiserver.config.k8s.io/v1";
    kind = "AdmissionConfiguration";
    plugins = [
      {
        name = "PodSecurity";
        configuration = {
          apiVersion = "pod-security.admission.config.k8s.io/v1";
          kind = "PodSecurityConfiguration";
          defaults = {
            enforce = "restricted";
            enforce-version = "latest";
            audit = "restricted";
            audit-version = "latest";
            warn = "restricted";
            warn-version = "latest";
          };
          excemptions = {
            usernames = [ ];
            runtimeClasses = [ ];
            namespaces = [
              "kube-system"
              "cis-operator-system"
            ];
          };
        };
      }
    ];
  };
  psaFile = genFile "psa" psaConf;

  defaultNWP = {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "intra-namespace";
      namespace = "kube-system";
    };
    spec = {
      podSelector = { };
      ingress = [ { from = [ { namespaceSelector.matchLabels.name = "kube-system"; } ]; } ];
    };
  };
  defaultNWPFile = genFile "deny-all" defaultNWP;

  allowDNS = namespace: {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "default-network-dns-policy";
      namespace = namespace;
    };
    spec = {
      ingress = [
        {
          ports =
            builtins.map
              (prot: {
                port = 53;
                protocol = prot;
              })
              [
                "TCP"
                "UDP"
              ];
        }
      ];
      podSelector.matchLabels.k8s-app = "kube-dns";
      policyTypes = [ "Ingress" ];
    };
  };
  allowDNSFile = namespace: genFile "allow-dns-${namespace}" (allowDNS namespace);

  allowMetrics = {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "allow-all-metrics-server";
      namespace = "kube-system";
    };
    spec = {
      podSelector.matchLabels.k8s-app = "metrics-server";
      ingress = [ { } ];
      policyTypes = [ "Ingress" ];
    };
  };
  allowMetricsFile = genFile "allow-metrics" allowMetrics;

  allowLB = {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "allow-all-svclbtraefik-ingress";
      namespace = "kube-system";
    };
    spec = {
      podSelector.matchLabels."svccontroller.k3s.cattle.io/svcname" = "traefik";
      ingress = [ { } ];
      policyTypes = [ "Ingress" ];
    };
  };
  allowLBFile = genFile "allow-lb" allowLB;

  allowIngress = {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "allow-all-traefik-ingress";
      namespace = "kube-system";
    };
    spec = {
      podSelector.matchLabels."app.kubernetes.io/name" = "traefik";
      ingress = [ { } ];
      policyTypes = [ "Ingress" ];
    };
  };
  allowIngressFile = genFile "allow-ingress" allowIngress;

in
{
  services.k3s.extraFlags = ''
    --kube-apiserver-arg="admission-control-config-file=${psaFile}"
  '';
}
