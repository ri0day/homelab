job "vaultwarden" {
    type = "service"

    group "vaultwarden" {
               volume "vaultwarden" {
      		type      = "host"
      		read_only = false
      		source    = "hostdir-vaultwarden"
    	    }
        network {
            port "http" {
                to = 80
            }
            port "websocket" {
                to = 3012
            }
        }
        service {
            check {
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "vaultwarden"
            provider = "nomad"
            port = "http"
            tags = [
"traefik.enable=true",
"traefik.http.routers.vaultwarden.rule=Host(`vault.mydomain.com`)",
"traefik.http.routers.vaultwarden.entrypoints=websecure",
"traefik.http.routers.vaultwarden.tls=true",
"traefik.http.routers.vaultwarden.tls.certresolver=letsencrypt"
]
        }
        task "vaultwarden" {
            driver = "docker"
            config {
                image = "docker.io/vaultwarden/server:1.30.0"
                ports = ["http", "websocket"]
            }
    template {
        destination = "${NOMAD_SECRETS_DIR}/env.txt"
        env         = true
        data        = <<EOT
ADMIN_TOKEN={{ with nomadVar "nomad/jobs/vaultwarden " }}{{ .ADMIN_TOKEN  }}{{ end }}
EOT
      }
            env {
                DOMAIN = "https://vault.mydomain.com"
                SIGNUPS_ALLOWED = false
                I_REALLY_WANT_VOLATILE_STORAGE=true
            }
            resources {
                cpu = 200
                memory = 64
            }
            volume_mount {
                volume = "vaultwarden"
                destination = "/data/"
                read_only = false
            }

        }
    }
}
