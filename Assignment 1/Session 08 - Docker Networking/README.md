# Docker Networking & Volumes — Hands-On Assignment

This assignment explores Docker's container networking modes and storage mechanisms through four practical tasks:
1. **Container Networking:** Designing custom bridge networks with network isolation and multi-homing.
2. **Host Networking:** Running a container directly on the host's network namespace.
3. **Bind Mounts:** Mounting a host directory into a running container to achieve instant live updates without rebuilds or restarts.
4. **Overlay Networking:** Researching and demonstrating multi-host networking with Docker Swarm and Virtual IP (VIP) load balancing.

---

## Student Details

| Field | Details |
|---|---|
| **Name** | Sambhav D Bohra |
| **Enrollment number** | 24bcs10090 |
| **Date** | 4 September 2026 |
| **Docker version** | 29.4.1 |

---

## Project Structure

| Path | Description |
|---|---|
| [`bind-mount-demo/`](bind-mount-demo/) | Directory on host machine bind-mounted into Nginx (Task 3) |
| [`screenshots/`](screenshots/) | Browser previews verifying Tasks 2 and 3 |

---

## Task 1 — Docker Container Networking

### Architecture Overview

To demonstrate real-world network segmentation (the classic 3-tier architecture), three containers were created across three custom bridge networks:
- **`frontend` (`nginx:alpine`)** connected to `frontend-net`
- **`backend` (`alpine:3.20`)** connected to **both** `frontend-net` and `backend-net`
- **`database` (`mysql:8.0`)** connected to `backend-net` and an admin network `db-admin-net`

This guarantees that the web frontend can talk to the backend, and the backend can talk to the database, but the **frontend has zero direct access to the database**.

```
        frontend-net                 backend-net              db-admin-net
   ┌────────────────────┐      ┌────────────────────┐      ┌──────────────┐
   │  frontend          │      │            database│      │ database     │
   │  (nginx:alpine)    │      │            (mysql) │      │ (admin path) │
   │  172.24.0.2        │      │         172.25.0.3 │      │ 172.26.0.2   │
   │                    │      │                    │      └──────────────┘
   │      backend ──────┼──────┼──── backend        │
   │      172.24.0.3    │      │     172.25.0.2     │
   └────────────────────┘      └────────────────────┘
              ▲                          ▲
              └──── single backend container, two interfaces ───┘
```

---

### Step 1: Create the User-Defined Bridge Networks

```bash
docker network create frontend-net
docker network create backend-net
docker network create db-admin-net
```

```
$ docker network ls
NETWORK ID     NAME           DRIVER    SCOPE
3e2520c3941a   backend-net    bridge    local
380a011dabce   bridge         bridge    local
73739be0c49a   db-admin-net   bridge    local
a9bf21e5858b   frontend-net   bridge    local
ca1c7c3c97b9   host           host      local
b7061e7020db   none           null      local
```

---

### Step 2: Launch the Three Containers

```bash
docker run -d --name frontend --network frontend-net nginx:alpine
docker run -d --name backend --network backend-net alpine:3.20 sleep infinity
docker run -d --name database --network backend-net -e MYSQL_ROOT_PASSWORD=StrongPass123 mysql:8.0
```

> **Note on Alpine:** The `sleep infinity` command prevents the minimal Alpine container from exiting immediately after start.

---

### Step 3: Attach the Multi-Homed Network Connections

Containers can only specify one initial network via `docker run`. Additional networks are attached using `docker network connect`:

```bash
docker network connect frontend-net backend
docker network connect db-admin-net database
```

Now `backend` is present on both `frontend-net` and `backend-net`, while `database` is on `backend-net` and `db-admin-net`.

---

### Step 4: Verify Network Memberships & IP Addresses

```
$ docker network inspect frontend-net --format '{{.Name}}: {{range .Containers}}{{.Name}} {{end}}'
frontend-net: backend frontend

$ docker network inspect backend-net --format '{{.Name}}: {{range .Containers}}{{.Name}} {{end}}'
backend-net: backend database

$ docker network inspect db-admin-net --format '{{.Name}}: {{range .Containers}}{{.Name}} {{end}}'
db-admin-net: database
```

Inspecting container IP allocations:

```
$ docker inspect backend --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}={{$v.IPAddress}} {{end}}'
backend-net=172.25.0.2 frontend-net=172.24.0.3

$ docker inspect frontend --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}={{$v.IPAddress}} {{end}}'
frontend-net=172.24.0.2

$ docker inspect database --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}={{$v.IPAddress}} {{end}}'
backend-net=172.25.0.3 db-admin-net=172.26.0.2
```

Each network operates on its own dedicated subnet (`172.24.0.0/16`, `172.25.0.0/16`, `172.26.0.0/16`).

---

### Step 5: Connectivity & Isolation Tests

| Source Container | Target Container | Shared Network | Expected Result | Actual Result |
|---|---|---|---|---|
| `backend` | `frontend` | `frontend-net` | Reachable | **0% packet loss** |
| `backend` | `database` | `backend-net` | Reachable | **0% packet loss** |
| `backend` | `database:3306` | `backend-net` | Port open | **Open (Connected)** |
| `frontend` | `database` | *None* | **Blocked** | **DNS failure (bad address)** |
| `frontend` | `backend` | `frontend-net` | Reachable | **0% packet loss** |

#### Test 1: Backend → Frontend (`frontend-net`)

```bash
docker exec backend ping -c 3 frontend
```

```
PING frontend (172.24.0.2): 56 data bytes
64 bytes from 172.24.0.2: seq=0 ttl=64 time=1.416 ms
64 bytes from 172.24.0.2: seq=1 ttl=64 time=0.129 ms
64 bytes from 172.24.0.2: seq=2 ttl=64 time=0.122 ms

--- frontend ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.122/0.555/1.416 ms
```

#### Test 2: Backend → Database (`backend-net`)

```bash
docker exec backend ping -c 3 database
```

```
PING database (172.25.0.3): 56 data bytes
64 bytes from 172.25.0.3: seq=0 ttl=64 time=1.024 ms
64 bytes from 172.25.0.3: seq=1 ttl=64 time=0.126 ms
64 bytes from 172.25.0.3: seq=2 ttl=64 time=0.124 ms

--- database ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.124/0.424/1.024 ms
```

#### Test 3: Backend → Database MySQL Port 3306

```bash
docker exec backend nc -zv database 3306
```

```
database (172.25.0.3:3306) open
```

#### Test 4: Frontend → Database (Network Isolation Proof)

```bash
docker exec frontend ping -c 2 database
```

```
ping: bad address 'database'
exit code = 1
```

> **Why this matters:** Because `frontend` and `database` do not share any network, Docker's embedded DNS server does not resolve the hostname `database` for the `frontend` container. Isolation is enforced at the network level by Docker itself.

#### Test 5: Frontend → Backend (`frontend-net`)

```bash
docker exec frontend ping -c 3 backend
```

```
PING backend (172.24.0.3): 56 data bytes
64 bytes from 172.24.0.3: seq=0 ttl=64 time=0.115 ms
64 bytes from 172.24.0.3: seq=1 ttl=64 time=0.129 ms
64 bytes from 172.24.0.3: seq=2 ttl=64 time=0.129 ms

--- backend ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.115/0.124/0.129 ms
```

---

### Key Takeaways from Task 1

1. **Automatic DNS Resolution:** User-defined bridge networks provide automatic container name resolution out of the box (unlike the legacy default bridge network).
2. **Network as a Security Boundary:** Multi-homing the middle tier (`backend`) allows controlled inter-service communication without exposing the database to the public/web tier.
3. **Container Name Reliability:** IP addresses can change upon container restart, so internal configuration should always rely on container DNS names.

---

## Task 2 — Host Network Mode

### Running Apache with `--network host`

In host networking mode, the container shares the network namespace of the host rather than getting its own isolated network stack:

```bash
docker pull httpd:2.4
docker run -d --name apache-host --network host httpd:2.4
```

Checking the container state:

```
$ docker ps --filter name=apache-host --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Networks}}'
NAMES         IMAGE       STATUS         PORTS     NETWORKS
apache-host   httpd:2.4   Up 4 seconds             host

$ docker inspect apache-host --format 'NetworkMode={{.HostConfig.NetworkMode}}'
NetworkMode=host
```

> **Key Observation:** Notice that the `PORTS` column is empty. In host mode, there is no port forwarding or NAT translation needed because Apache binds directly to port 80 of the host network stack.

Server logs confirm successful startup:

```
$ docker logs apache-host
[Tue Sep 01 12:57:54.258600 2026] [mpm_event:notice] [pid 1:tid 1] AH00489: Apache/2.4.68 (Unix) configured -- resuming normal operations
[Tue Sep 01 12:57:54.259524 2026] [core:notice] [pid 1:tid 1] AH00094: Command line: 'httpd -D FOREGROUND'
```

---

### Accessing Apache on Port 80

Verifying from inside the host network namespace:

```bash
docker run --rm --network host alpine:3.20 wget -qO- http://localhost:80
```

```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
```

### Platform Behavior Note (Docker Desktop vs Native Linux)

- **On Native Linux:** `--network host` binds directly to the physical host machine's interfaces. Visiting `http://localhost:80` directly in the host's browser works immediately.
- **On Docker Desktop (macOS / Windows):** Docker runs inside a lightweight Linux VM. Host networking attaches to the VM's network stack rather than the macOS/Windows host network directly.
- To also verify browser access on host port 80 across all environments, the container was run with standard port publishing (`-p 80:80`):

```bash
docker run -d --name apache-port80 -p 80:80 httpd:2.4
```

```
$ curl -i http://localhost:80
HTTP/1.1 200 OK
Server: Apache/2.4.68 (Unix)
Content-Type: text/html

<html><body><h1>It works!</h1></body></html>
```

![Apache running on port 80](screenshots/apache-port80.png)

---

### Bridge vs. Host Network Comparison

| Feature | Bridge Mode (Default) | Host Mode (`--network host`) |
|---|---|---|
| **Network Namespace** | Isolated per container | Shared with the host |
| **Port Mapping** | Required (`-p <host>:<container>`) | Direct binding (no `-p` flag) |
| **IP Address** | Dedicated private IP (e.g., `172.17.0.x`) | Host's IP address |
| **Port Conflicts** | Isolated across containers | Containers can conflict on same port |
| **Performance Overhead** | Minimal (NAT routing) | Maximum performance (Zero NAT) |
| **Best Used For** | Microservices, general applications | High-performance networking, host monitoring |

---

## Task 3 — Bind Mounts (Live Reload Demonstration)

### Step 1: Create Host Directory & HTML File

```bash
mkdir bind-mount-demo
cat << 'EOF' > bind-mount-demo/index.html
<!doctype html>
<html>
  <head><title>Bind Mount Demo</title></head>
  <body style="font-family:sans-serif;text-align:center;padding-top:60px">
    <h1>Hello students</h1>
  </body>
</html>
EOF
```

---

### Step 2: Start Nginx with the Bind Mount

We mount our local `bind-mount-demo` folder directly into Nginx's HTML serving path as read-only (`:ro`):

```bash
docker run -d --name nginx-bindmount -p 8090:80 \
    -v "$PWD/bind-mount-demo:/usr/share/nginx/html:ro" nginx:alpine
```

Inspecting the mount configuration:

```
$ docker inspect nginx-bindmount --format '{{range .Mounts}}{{.Type}} {{.Source}} -> {{.Destination}} (RW={{.RW}}){{end}}'
bind .../bind-mount-demo -> /usr/share/nginx/html (RW=false)
```

The mount type is explicitly **`bind`** and `RW=false` confirms read-only security.

---

### Step 3: Initial Verification

```
$ curl -s http://localhost:8090
<!doctype html>
<html>
  <head><title>Bind Mount Demo</title></head>
  <body style="font-family:sans-serif;text-align:center;padding-top:60px">
    <h1>Hello students</h1>
  </body>
</html>
```

![Before Edit Screenshot](screenshots/bindmount-before.png)

---

### Step 4: Live File Modification Without Restarting Container

To prove the container is never stopped or restarted, we record its start timestamp:

```
$ docker inspect nginx-bindmount --format '{{.State.StartedAt}}'
2026-09-01T12:59:06.535144495Z
```

Next, edit `bind-mount-demo/index.html` on the host machine:

```html
<!doctype html>
<html>
  <head><title>Bind Mount Demo - Updated</title></head>
  <body style="font-family:sans-serif;text-align:center;padding-top:60px">
    <h1>Hello students - file edited on the host!</h1>
    <p>This change appeared without restarting the Nginx container.</p>
  </body>
</html>
```

Now request the endpoint again immediately:

```
$ curl -s http://localhost:8090
<!doctype html>
<html>
  <head><title>Bind Mount Demo - Updated</title></head>
  <body style="font-family:sans-serif;text-align:center;padding-top:60px">
    <h1>Hello students - file edited on the host!</h1>
    <p>This change appeared without restarting the Nginx container.</p>
  </body>
</html>
```

---

### Proof of Continuous Uptime (Zero Restart)

```
$ docker inspect nginx-bindmount --format '{{.State.StartedAt}}'
2026-09-01T12:59:06.535144495Z          <-- Exactly identical timestamp

$ docker ps --filter name=nginx-bindmount --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
NAMES             STATUS          PORTS
nginx-bindmount   Up 33 seconds   0.0.0.0:8090->80/tcp, [::]:8090->80/tcp
```

The container maintained continuous uptime throughout the modification.

![After Edit Screenshot](screenshots/bindmount-after.png)

---

### Bind Mounts vs. Named Volumes

| Feature | Bind Mount | Named Volume |
|---|---|---|
| **Syntax** | `-v /host/path:/container/path` | `-v my_volume:/container/path` |
| **Location** | Exact location chosen by user on host | Managed by Docker (`/var/lib/docker/volumes`) |
| **Host Dependency** | High (tied to host filesystem structure) | Low (portable across environments) |
| **Primary Use Case** | **Local development** (live code reloading) | **Production persistence** (databases, stateful apps) |

---

## Task 4 — Overlay Networks (Multi-Host Networking)

### Concept & Research

While **bridge** networks are restricted to a single Docker daemon/host, **overlay networks** allow containers running on separate physical machines or virtual nodes to communicate seamlessly on a flat virtual subnet without manual port forwarding.

#### How Overlay Networks Function
1. **VXLAN Encapsulation:** Containers send standard Ethernet frames, which are encapsulated into UDP packets (port **4789**) and sent over the underlying physical network.
2. **Distributed Control Plane:** Docker Swarm manages discovery and routing across nodes using an encrypted gossip protocol on TCP/UDP **7946** and cluster management on TCP **2377**.
3. **Virtual IP (VIP) Load Balancing:** Swarm assigns a single VIP to a service name, transparently load-balancing client requests across healthy replica containers.

---

### Demonstration with Docker Swarm

To verify overlay network functionality:

```bash
docker swarm init
docker network create -d overlay --attachable app-overlay
```

```
$ docker network ls --filter driver=overlay
NETWORK ID     NAME          DRIVER    SCOPE
g0nvn8vqioen   app-overlay   overlay   swarm
1x0x4x1mzk06   ingress       overlay   swarm
```

Notice the **`SCOPE = swarm`**, distinguishing it from single-host local drivers.

#### Deploy a Replicated Service Across the Overlay:

```bash
docker service create --name web --network app-overlay --replicas 3 -p 8095:80 nginx:alpine
```

```
$ docker service ls
ID             NAME      MODE         REPLICAS   IMAGE          PORTS
ct2j0ud9b6x8   web       replicated   3/3        nginx:alpine   *:8095->80/tcp

$ docker service ps web
NAME      NODE             DESIRED STATE   CURRENT STATE
web.1     docker-desktop   Running         Running 19 seconds ago
web.2     docker-desktop   Running         Running 19 seconds ago
web.3     docker-desktop   Running         Running 19 seconds ago
```

#### Service Discovery and VIP Resolution:

```
$ docker run --rm --network app-overlay alpine:3.20 nslookup web
Name:	web
Address: 10.0.1.2
```

The DNS name `web` resolves to a Virtual IP (`10.0.1.2`), providing automatic load balancing among all 3 replicas.

---

### Clean up Swarm Resources

```bash
docker service rm web
docker network rm app-overlay
docker swarm leave --force
```

---

## Docker Network Drivers Summary

| Driver | Scope | Main Purpose |
|---|---|---|
| `bridge` | Single host | Default isolated container network |
| `host` | Single host | Shares host network stack directly |
| `overlay` | Multi-host | Connects containers across multiple nodes (Swarm) |
| `macvlan` | Single host | Assigns physical MAC addresses to containers |
| `none` | Single host | Completely disables networking for container |

---

## Cleanup Script for Tasks 1–3

```bash
# Remove all containers
docker rm -f frontend backend database apache-port80 nginx-bindmount

# Remove custom networks
docker network rm frontend-net backend-net db-admin-net
```
