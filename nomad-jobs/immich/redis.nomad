job "immich-redis" {
  type = "service"

  group "immich-redis" {
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
      template {
        data        = <<EOH
	AUTH_TOKEN={{ with nomadVar "nomad/jobs/immich-redis" }}{{ .PASSWORD }}{{ end }}
	EOH
        destination = "local/env.txt"
        env         = true
      }
      config {
        image = "redis:7.0.7-alpine"
        ports = ["redis"]
        args = ["--requirepass", "${AUTH_TOKEN}"]
      }
    }
  }
}
