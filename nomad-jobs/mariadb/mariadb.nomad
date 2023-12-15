job "mariadb" {
  type = "service"

constraint {
  attribute = "${attr.cpu.arch}"
  value     = "arm64"
}

  group "mariadb" {
    count = 1
    network {
      port "mariadb" {
        to = 3306
      }
    }

    service {
      name     = "mariadb-svc"
      port     = "mariadb"
      provider = "nomad"
    }

    task "mariadb-task" {
      driver = "docker"
      template {
        data        = <<EOH
MARIADB_PASSWORD={{ with nomadVar "nomad/jobs/mariadb" }}{{ .MARIADB_PASSWORD  }}{{ end }}
MARIADB_ROOT_PASSWORD={{ with nomadVar "nomad/jobs/mariadb" }}{{ .MARIADB_ROOT_PASSWORD  }}{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
       env {
      MARIADB_AUTO_UPGRADE="1"
      MARIADB_INITDB_SKIP_TZINFO="1"
      MARIADB_DATABASE="playground"
      MARIADB_USER="playuser"
        }
   resources {
        cpu    = 512
        memory = 1024
    } 
      config {


        image = "mariadb:10.11"
        ports = ["mariadb"]
        command = "mariadbd"
        args = [
        "--innodb-buffer-pool-size=512M", "--transaction-isolation=READ-COMMITTED",
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci",
        "--max-connections=512",
        "--innodb-rollback-on-timeout=OFF",
        "--innodb-lock-wait-timeout=120",
      ]  
      }
    }
  }
}
