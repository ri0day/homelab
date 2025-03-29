job "immich-postgres" {
  type = "service"

constraint {
  attribute = "${attr.cpu.arch}"
  value     = "amd64"
}

  group "immich-postgres" {
    count = 1
    network {
      port "pg" {
        to = 5432
      }
    }

    service {
      name     = "pg-svc"
      port     = "pg"
      provider = "nomad"
    }

    task "postgres-task" {
      driver = "docker"
      template {
        data        = <<EOH
POSTGRES_PASSWORD={{ with nomadVar "nomad/jobs/immich-postgres" }}{{ .DB_PASSWORD  }}{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
       env {
      POSTGRES_USER = "postgres"
      POSTGRES_DB = "immich"
      TZ ="Asia/Shanghai"
      }
      config {
        image = "tensorchord/pgvecto-rs:pg14-v0.2.0"
        ports = ["pg"]
              security_opt = [
        "seccomp:unconfined",
        "apparmor:unconfined",
       ]
        volumes = [
          "/opt/immich/pg-data:/var/lib/postgresql/data",
        ]
      }
    }
  }
}
