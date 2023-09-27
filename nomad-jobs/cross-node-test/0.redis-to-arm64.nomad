job "pytechco-redis" {
  type = "service"

constraint {
  attribute = "${attr.cpu.arch}"
  value     = "arm64"
}

  group "ptc-redis" {
    count = 1
    network {
      port "redis" {
        to = 6379
      }
    }

    service {
      name     = "redis-svc"
      port     = "redis"
      provider = "nomad"
    }

    task "redis-task" {
      driver = "docker"

      config {
        image = "redis:7.0.7-alpine"
        ports = ["redis"]
      }
    }
  }
}
