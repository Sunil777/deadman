````markdown
# Deadman's Snitch

A dead simple snitch for the Prometheus Alertmanager.  
An external service is needed with deadman's snitch functionality to make sure the alerting pipeline is working.

---

## Installation

### From Source

To build:

make build
````

To install globally (default `/usr/local/bin`):

```bash
sudo make install
```

Or to install in a custom directory:

```bash
sudo make install INSTALL_DIR=/opt/bin
```

To uninstall:

```bash
sudo make uninstall
```

To clean build artifacts:

```bash
make clean
```

### From Docker

To build the Docker image:

```bash
make docker
```

---

## Usage

To see available options:

```bash
./deadman -h
```

Example run:

```bash
./deadman \
  --am.url="http://localhost:9093/api/v2/alerts" \
  --deadman.interval=30s \
  --log.level=info
```

---

## Prometheus Rule

Add this rule to the Prometheus server to continuously generate alerts:

```yaml
- alert: DeadManBoy
  expr: vector(1)
  labels:
    severity: deadman
  annotations:
    description: This is a DeadMansSwitch meant to ensure that the entire Alerting
      pipeline is functional.
```

---

## Alertmanager Configuration

In the Alertmanager cluster, add a route to send webhook notifications to the deadman process:

```yaml
- receiver: deadmans-switch
  group_wait: 0s
  group_interval: 0s
  repeat_interval: 15s
  match:
    severity: deadman

- name: deadmans-switch
  webhook_configs:
  - url: http://deadman-ip:9095
```

---

## Systemd Service Example

Create a file `/etc/systemd/system/deadman.service`:

```ini
[Unit]
Description=Deadman Snitch for Prometheus Alertmanager
After=network.target

[Service]
ExecStart=/usr/local/bin/deadman \
  --am.url="http://localhost:9093/api/v2/alerts" \
  --deadman.interval=30s \
  --log.level=info
Restart=on-failure
RestartSec=5
User=deadman
Group=deadman
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Reload systemd and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now deadman
```

Check logs:

```bash
journalctl -u deadman -f
```

---

## Deployment

Run an Alertmanager co-located with the deadman process which will notify you for all the alerts it receives.