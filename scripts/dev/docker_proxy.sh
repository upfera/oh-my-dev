#!/bin/bash
set -e

echo "🔧 Creating registry config for Docker Hub proxy..."
sudo rm -rf /etc/docker/registry
sudo mkdir -p /etc/docker/registry
cat <<EOF | sudo tee /etc/docker/registry/config.yml > /dev/null
version: 0.1
http:
  addr: :5000
storage:
  filesystem:
    rootdirectory: /var/lib/registry
proxy:
  remoteurl: https://registry-1.docker.io
EOF

echo "📦 Creating persistent storage..."
sudo rm -rf /opt/registry
sudo mkdir -p /opt/registry

echo "⚙️ Creating systemd service..."
sudo tee /etc/systemd/system/registry.service > /dev/null <<'EOF'
[Unit]
Description=Local Podman Registry Caching Proxy
After=network.target

[Service]
ExecStart=/usr/bin/podman run --rm \
  -p 32000:5000 \
  -v /etc/docker/registry:/etc/docker/registry:Z \
  -v /opt/registry:/var/lib/registry:Z \
  registry:2
ExecStop=/usr/bin/podman stop registry
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd and enabling registry service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now registry

echo "🛠 Configuring Podman to use local registry as mirror..."
sudo mkdir -p /etc/containers/registries.conf.d
sudo tee /etc/containers/registries.conf.d/mirror.conf > /dev/null <<EOF
[[registry]]
location = "docker.io"
mirror-by-digest-only = false

[[registry.mirror]]
location = "localhost:32000"
insecure = true
EOF

sudo systemctl restart registry

echo "✅ Done. Test with: podman pull docker.io/library/hello-world"
