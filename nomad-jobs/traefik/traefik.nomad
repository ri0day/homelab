job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port  "http"{
         static = 80
      }
      port  "https"{
         static = 443
      }

      port "api" {
        static = 8080
      }


    }

    service {
      name = "traefik-dashboard"
      provider = "nomad"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.dashboard.rule=Host(`traefik.mydomain.com`)",
        "traefik.http.routers.dashboard.service=api@internal",
        "traefik.http.routers.dashboard.entrypoints=web",
        "traefik.http.routers.dashboard.middlewares=auth",
        "traefik.http.middlewares.auth.basicauth.users=admin:$apr1$NwDkfkIf$9C5v3DrYUtWoD4kvAoct90"
      ]

      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }


    service {
       name = "traefik-https"
       provider = "nomad"
       port = "https"
     }

    task "server" {
      driver = "docker"
      template {
        data        = <<EOH
CF_DNS_API_TOKEN={{ with nomadVar "nomad/jobs/traefik" }}{{ .CF_DNS_API_TOKEN }}{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
      config {
        image = "traefik:v3.3.4"
        network_mode = "host"
        ports = [ "http", "api","https"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", ### For Test only, please do not use that in production
          "--log.level=DEBUG",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entryPoints.websecure.address=:${NOMAD_PORT_https}",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://100.69.203.150:4646", ### IP to your nomad server
          "--certificatesresolvers.letsencrypt.acme.email=${CF_API_EMAIL}",
          "--certificatesresolvers.letsencrypt.acme.storage=acme.json",
          "--certificatesresolvers.letsencrypt.acme.dnschallenge=true",
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare",
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.delaybeforecheck=0",
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.resolvers=1.1.1.1:53,8.8.8.8:53"
        ]
      }
    }
  }
}
