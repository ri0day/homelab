job "synchting-app" {
  datacenters = ["dc1"]

constraint {
  attribute = "${attr.cpu.arch}"
  value     = "amd64"
}
  type = "service"

  group "synchting-app" {
    count = 1

    network {
       mode = "host"
       port "http" {
         to = 8384
       }
       port "transfer" {
         to = 22000 
         static = 22000
       }
       port "discovery" {
        to = 21027
        static = 21027
       }
    }

    service {
      name = "synchting-app"
      port = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.synchting-app.entrypoints=websecure",
        "traefik.http.routers.synchting-app.rule=Host(`syncthing.mydomain.com`)",
        "traefik.http.routers.synchting-app.tls=true",
        "traefik.http.routers.synchting-app.tls.certresolver=letsencrypt",
        "traefik.http.routers.synchting-app.tls.domains[0].main=syncthing.mydomain.com"
      ]
    }

    task "server" {
      driver = "docker"

        env {
         PUID=1000
         PGID=1000
        }
      config {
        image = "syncthing/syncthing:latest"
        ports = ["http","transfer","discovery"]
        volumes = [
          "/mnt/syncthing:/var/syncthing", #/mnt/syncthing directory owned by uid user on host
        ]
      }
    }
  }
}
