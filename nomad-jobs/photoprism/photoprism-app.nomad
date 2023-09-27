job "photoprism-app" {
  datacenters = ["dc1"]

constraint {
  attribute = "${attr.cpu.arch}"
  value     = "amd64"
}
  type = "service"

  group "photoprism-app" {
    count = 1

    network {
       port "http" {
         to = 2342
       }
    }

    service {
      name = "photoprism-app"
      port = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.photoprism-app.entrypoints=websecure",
        "traefik.http.routers.photoprism-app.rule=Host(`photoprism.mydomain.com`)",
        "traefik.http.routers.photoprism-app.tls=true",
        "traefik.http.routers.photoprism-app.tls.certresolver=letsencrypt",
        "traefik.http.routers.photoprism-app.tls.domains[0].main=photoprism.mydomain.com"
      ]
    }

    task "server" {
      env {
      PHOTOPRISM_AUTH_MODE=password
      PHOTOPRISM_DISABLE_TLS=true               
      PHOTOPRISM_DEFAULT_TLS=false                
      PHOTOPRISM_ORIGINALS_LIMIT=5000              
      PHOTOPRISM_HTTP_COMPRESSION=gzip
      PHOTOPRISM_LOG_LEVEL=info           
      PHOTOPRISM_READONLY=false                  
      PHOTOPRISM_EXPERIMENTAL=false              
      PHOTOPRISM_DISABLE_CHOWN=false             
      PHOTOPRISM_DISABLE_WEBDAV=false            
      PHOTOPRISM_DISABLE_SETTINGS=false          
      PHOTOPRISM_DISABLE_TENSORFLOW=false        
      PHOTOPRISM_DISABLE_FACES=false             
      PHOTOPRISM_DISABLE_CLASSIFICATION=false    
      PHOTOPRISM_DISABLE_VECTORS=false           
      PHOTOPRISM_DISABLE_RAW=false               
      PHOTOPRISM_RAW_PRESETS=false               
      PHOTOPRISM_JPEG_QUALITY=85                   
      PHOTOPRISM_DETECT_NSFW=false              
      PHOTOPRISM_UPLOAD_NSFW=true               
      PHOTOPRISM_DATABASE_DRIVER=sqlite 
      }
      template {
        data        = <<EOH
PHOTOPRISM_ADMIN_PASSWORD={{ with nomadVar "nomad/jobs/photoprism-app" }}{{  .PHOTOPRISM_ADMIN_PASSWORD }}{{ end }}
PHOTOPRISM_SITE_URL={{ with nomadVar "nomad/jobs/photoprism-app" }}{{  .PHOTOPRISM_SITE_URL }}{{ end }}
PHOTOPRISM_DATABASE_NAME={{ with nomadVar "nomad/jobs/photoprism-app" }}{{ .PHOTOPRISM_DATABASE_NAME  }}{{ end }}
PHOTOPRISM_DATABASE_USER={{ with nomadVar "nomad/jobs/photoprism-app" }}{{ .PHOTOPRISM_DATABASE_USER  }}{{ end }}
PHOTOPRISM_DATABASE_PASSWORD={{ with nomadVar "nomad/jobs/photoprism-app" }}{{ .PHOTOPRISM_DATABASE_PASSWORD  }}{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
   resources {
        cpu    = 2048
        memory = 2048
    } 
      driver = "docker"

      config {
        image = "photoprism/photoprism:latest"
        ports = ["http"]
        security_opt = [
        "seccomp:unconfined",
        "apparmor:unconfined",
       ]
        volumes = [
          "/opt/photoprism/originals:/photoprism/originals",
          "/opt/photoprism/import:/photoprism/import",
          "/opt/photoprism/data:/photoprism/storage",
          "/opt/photoprism/tmp:/photoprism/tmp",
        ]
      }
    }
  }
}
