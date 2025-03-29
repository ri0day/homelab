job "etherpad" {
    type = "service"


constraint {
  attribute = "${attr.cpu.arch}"
  value     = "arm64"
}
    group "etherpad" {
        network {
            port "web" {
                to = 9001
            }
        }
        service {
            check {
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "etherpad"
            provider = "nomad"
            port = "web"
            tags = [
"traefik.enable=true",
"traefik.http.routers.etherpad.rule=Host(`etherpad.boringbear.eu.org`)",
"traefik.http.routers.etherpad.entrypoints=websecure",
"traefik.http.routers.etherpad.tls=true",
"traefik.http.routers.etherpad.tls.certresolver=letsencrypt"
]
        }
        task "etherpad" {
            driver = "docker"
            config {
                image = "docker.io/etherpad/etherpad:latest"
                ports = ["web"]
            }
    template {
        destination = "${NOMAD_SECRETS_DIR}/env.txt"
        env         = true
        data        = <<EOT
ADMIN_PASSWORD={{ with nomadVar "nomad/jobs/etherpad" }}{{ .ADMIN_PASS  }}{{ end }} 
DB_USER={{ with nomadVar "nomad/jobs/etherpad" }}{{ .DB_USER  }}{{ end }}
DB_PASS={{ with nomadVar "nomad/jobs/etherpad" }}{{ .DB_PASS  }}{{ end }}
{{ range nomadService "mariadb-svc" }}
DB_HOST={{ .Address }}
DB_PORT={{ .Port }}
{{ end }}
EOT
      }
            env {
                NODE_ENV = "production"
                DB_TYPE = "mysql"
		DB_CHARSET= "utf8mb4"
		DB_NAME="playground"
            }
            resources {
                cpu = 1000
                memory = 512
            }

        }
    }
}
