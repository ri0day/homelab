job "immich-app" {
  datacenters = ["dc1"]

constraint {
  attribute = "${attr.cpu.arch}"
  value     = "amd64"
}
  type = "service"

  group "immich-app" {
    count = 1

    network {
       port "http" {
         to = 8080
       }
    }

    service {
      name = "immich-app"
      port = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.immich-app.entrypoints=websecure",
        "traefik.http.routers.immich-app.rule=Host(`immich.mydomain.com`)",
        "traefik.http.routers.immich-app.tls=true",
        "traefik.http.routers.immich-app.tls.certresolver=letsencrypt",
        "traefik.http.routers.immich-app.tls.domains[0].main=immich.mydomain.com"
      ]
    }

    task "server" {
      env {
      TZ = "Asia/Shanghai"
      PUID = "1000"
      PGID = "1000"
      DB_USERNAME = "postgres"
      DB_DATABASE_NAME = "immich"
      MACHINE_LEARNING_HOST = "0.0.0.0"
      MACHINE_LEARNING_PORT = "3003"
      MACHINE_LEARNING_WORKERS = "1"
      MACHINE_LEARNING_WORKER_TIMEOUT = "120"
      }
      template {
        data        = <<EOH
DB_PASSWORD={{ with nomadVar "nomad/jobs/immich-app" }}{{  .DB_PASSWORD }}{{ end }}
REDIS_PASSWORD={{ with nomadVar "nomad/jobs/immich-app" }}{{ .REDIS_PASSWORD  }}{{ end }}
{{ range nomadService "redis-svc" }}
REDIS_HOSTNAME={{ .Address }}
REDIS_PORT={{ .Port }}
{{ end }}
{{ range nomadService "pg-svc" }}
DB_HOSTNAME={{ .Address }}
DB_PORT={{ .Port }}
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
   resources {
        cpu    = 1024
        memory = 1024
    } 
      driver = "docker"

      config {
        image = "ghcr.io/imagegenius/immich:latest"
        ports = ["http"]
        security_opt = ["seccomp:unconfined","apparmor:unconfined"]
        volumes = [
         "/opt/immich/photos:/photos",
         "/opt/immich/config:/config",
         "/opt/immich/libraries:/libraries",
        ]
      }
    }
  }
}
