{ config, ... }:
let secret = "grafana-agent-apikey";
in {
  services.grafana-agent = {
    enable = true;
    settings = {
      metrics = {
        configs = [{
          name = "wvwbot";
          scrape_configs = [{
            job_name = "bot";
            static_configs = {
              targets = [ "localhost:${config.wvwbot.metricsPort}" ];
            };
          }];
          remote_write = [{
            url =
              "https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push";
            basic_auth = {
              username = 785788;
              password_file = "/run/keys/${secret}";
            };
          }];
        }];
      };

      traces = {
        configs = [{
          name = "wvwbot";
          remote_write = [{
            endpoint = "tempo-eu-west-0.grafana.net:443";
            basic_auth = {
              username = 388376;
              password_file = "/run/keys/${secret}";
            };
          }];
          receivers = {
            jaeger = {
              protocols = {
                grpc = { }; # 14250
                thrift_binary = { }; # 6832
                thrift_compact = { }; # 6831
                thrift_http = { }; # 14268
              };
            };
            zipkin = { }; # 9411
            otlp = {
              protocols = {
                http = { }; # 4318
                grpc = { }; # 4317
              };
            };
            opencensus = { }; # 55678
          };
        }];
      };

      server = {
        http_listen_port = 12345;
        log_level = "info";
      };
    };
  };

  keys."${secret}" = { };
  systemd.services.grafana-agent.wants = [ "${secret}-key.service" ];
}
