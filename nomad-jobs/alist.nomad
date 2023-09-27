job "alist3" {
    type = "service"

    group "alist3" {
               volume "alist3" {
      		type      = "host"
      		read_only = false
      		source    = "hostdir-alist3"
    	    }
        network {
            port "http" {
                to = 5244
            }
        }
        service {
            check {
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "alist3"
            provider = "nomad"
            port = "http"
            tags = [
"traefik.enable=true",
"traefik.http.routers.alist3.rule=Host(`alist.mydomain.com`)",
"traefik.http.routers.alist3.entrypoints=websecure",
"traefik.http.routers.alist3.tls=true",
"traefik.http.routers.alist3.tls.certresolver=letsencrypt"
]
        }
        task "alist3" {
            driver = "docker"
            config {
                image = "docker.io/xhofe/alist:v3.25.1"
                ports = ["http"]
            }
            env {
                PUID = 0
                PGID = 0
                UMASK = 022
            }
            volume_mount {
                volume = "alist3"
                destination = "/opt/alist/data/"
                read_only = false
            }

        }
    }
}
