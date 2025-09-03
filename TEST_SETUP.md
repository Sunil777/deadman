```markdown
# Deadman Snitch Test Setup

This setup allows you to **test the Deadman snitch** with Prometheus and Alertmanager using Docker Compose.
```
---

## Directory Structure

```

test-setup/
├── docker-compose.yml
├── prometheus.yml
├── rules.yml
├── alertmanager.yml
└── TEST_SETP.md

````

---

## Docker Compose Services

- **prometheus** – Prometheus server to generate and scrape alerts.
- **alertmanager** – Alertmanager to route alerts to Deadman.
- **deadman** – The Deadman snitch service that receives webhook alerts.

---

## Setup and Run

1. **Build and start the test setup**

```bash
cd test-setup
docker-compose -p deadmantest1 up --build
````

* `-p deadmantest1` sets the project name to avoid conflicts with other Compose projects.
* Use `--build` to rebuild images if you made changes.

2. **Stopping Prometheus temporarily**

```bash
docker-compose -p deadmantest1 stop prometheus
```

3. **Start Prometheus again**

```bash
docker-compose -p deadmantest1 start prometheus
```

4. **Restart Prometheus**

```bash
docker-compose -p deadmantest1 restart prometheus
```

5. **Stop all services**

```bash
docker-compose -p deadmantest1 down
```

---

## Prometheus Rules

Add a `DeadManBoy` alert in `rules.yml`:

```yaml
groups:
  - name: deadman
    rules:
      - alert: DeadManBoy
        expr: vector(1)
        labels:
          severity: deadman
        annotations:
          description: This is a DeadMansSwitch meant to ensure the alerting pipeline is functional.
```

Make sure Prometheus references this in `prometheus.yml`:

```yaml
rule_files:
  - /etc/prometheus/rules.yml
```

---

## Alertmanager Configuration (`alertmanager.yml`)

```yaml
route:
  receiver: default-receiver
  group_wait: 1s
  group_interval: 1s
  repeat_interval: 15s
  routes:
    - receiver: deadmans-switch
      match:
        severity: deadman
      group_wait: 1s
      group_interval: 1s
      repeat_interval: 15s

receivers:
  - name: default-receiver
    webhook_configs:
      - url: http://example-webhook:9091

  - name: deadmans-switch
    webhook_configs:
      - url: http://deadman:9095
```

**Notes:**

* `default-receiver` handles unmatched alerts.
* `deadmans-switch` handles alerts with `severity: deadman`.
* `group_wait` and `group_interval` must be ≥1s.

---

## Deadman Missed Heartbeat Test

This test shows what happens if Prometheus stops sending alerts:

1. **Start the test setup**

```bash
docker-compose -p deadmantest1 up --build
```

2. **Observe Deadman receiving alerts**

* Deadman receives `DeadManBoy` alerts continuously from Prometheus via Alertmanager.
* Logs in Deadman container:

```bash
docker logs -f deadmantest1_deadman_1
```

You should see timestamps showing alerts received every interval (default 30s).

3. **Stop Prometheus temporarily**

```bash
docker-compose -p deadmantest1 stop prometheus
```

* Prometheus stops sending `DeadManBoy` alerts.
* After the configured heartbeat interval, Deadman will **trigger a new alert** indicating the pipeline is down, e.g., `DeadManDead`.

4. **Observe new Deadman alert**

* Alertmanager will now show `DeadManDead` alert as the Deadman snitch detects missed heartbeats.
* Deadman logs will show that no alerts were received for the expected interval.

5. **Restart Prometheus**

```bash
docker-compose -p deadmantest1 start prometheus
```

* Deadman starts receiving `DeadManBoy` alerts again.
* The `DeadManDead` alert resolves automatically in Alertmanager.
* Normal monitoring resumes.

---

### Notes

* The Deadman interval is configurable (default: 30s) using `--deadman.interval`.
* This simulates alerting pipeline failures and ensures your alerting system reacts when Prometheus stops sending metrics.
* You can change the alert name from `DeadManDead` if desired in Deadman’s configuration or code.
