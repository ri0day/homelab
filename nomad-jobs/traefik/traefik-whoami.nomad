job "traefik-whoami" {
  datacenters = ["dc1"]

  type = "service"

  group "traefik-whoami" {
    count = 1

    network {
       port "http" {
         to = 8080
       }
    }

    service {
      name = "traefik-whoami"
      port = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik-whoami.entrypoints=websecure",
        "traefik.http.routers.traefik-whoami.rule=Host(`whoami.mydomain.com`)",
        "traefik.http.routers.traefik-whoami.tls=true",
        "traefik.http.routers.traefik-whoami.tls.certresolver=letsencrypt",
        "traefik.http.routers.traefik-whoami.tls.domains[0].main=whoami.mydomain.com"
      ]
    }

    task "server" {
      env {
        WHOAMI_PORT_NUMBER = "${NOMAD_PORT_http}"
      }

      driver = "docker"

      config {
        image = "traefik/whoami"
        ports = ["http"]
      }
    }
  }
}
