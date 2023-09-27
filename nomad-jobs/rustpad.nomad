job "rustpad" {
  datacenters = ["dc1"]

  type = "service"

  group "rustpad" {
    count = 1

    network {
       port "http" {
         to = 3030
       }
    }

    service {
      name = "rustpad"
      port = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.rustpad.entrypoints=websecure",
        "traefik.http.routers.rustpad.rule=Host(`rustpad.mydomain.com`)",
        "traefik.http.routers.rustpad.tls=true",
        "traefik.http.routers.rustpad.tls.certresolver=letsencrypt",
        "traefik.http.routers.rustpad.tls.domains[0].main=rustpad.mydomain.com"
      ]
    }

    task "server" {
      env {
        WHOAMI_PORT_NUMBER = "${NOMAD_PORT_http}"
      }

      driver = "docker"

      config {
        image = "ekzhang/rustpad:latest"
        ports = ["http"]
      }
    }
  }
}
