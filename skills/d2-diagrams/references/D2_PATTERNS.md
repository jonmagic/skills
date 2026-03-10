# D2 Diagram Patterns

Common diagram patterns and templates for real-world use cases.

## Table of Contents

- [Simple Flowchart](#simple-flowchart)
- [System Architecture](#system-architecture)
- [Microservices Architecture](#microservices-architecture)
- [Entity-Relationship Diagram](#entity-relationship-diagram)
- [Sequence Diagram - API Flow](#sequence-diagram---api-flow)
- [Network Topology](#network-topology)
- [CI/CD Pipeline](#cicd-pipeline)
- [Class Hierarchy](#class-hierarchy)
- [State Machine](#state-machine)
- [Dashboard Grid](#dashboard-grid)
- [Cloud Infrastructure](#cloud-infrastructure)
- [Data Pipeline](#data-pipeline)
- [Decision Tree](#decision-tree)

---

## Simple Flowchart

```d2
direction: down

start: Start {shape: oval}
input: Get User Input
validate: Valid? {shape: diamond}
process: Process Data
error: Show Error
output: Display Result
end: End {shape: oval}

start -> input -> validate
validate -> process: Yes
validate -> error: No
error -> input
process -> output -> end
```

---

## System Architecture

```d2
direction: down

classes: {
  frontend: {
    style: {
      fill: "#e3f2fd"
      stroke: "#1565c0"
      border-radius: 10
    }
  }
  backend: {
    style: {
      fill: "#fff3e0"
      stroke: "#e65100"
      border-radius: 10
    }
  }
  data: {
    style: {
      fill: "#e8f5e9"
      stroke: "#2e7d32"
      border-radius: 10
    }
  }
}

# Titled container + transparent md child pattern:
# Container gets border-radius, md child holds rich content
client: Client Layer {
  class: frontend

  details: |md
- Web App (React SPA)
- Mobile App (React Native)
| {
    style.fill: transparent
    style.stroke: transparent
  }
}

api: API Layer {
  class: backend

  details: |md
- API Gateway — routing
- Auth Service — JWT validation
- Core Service — business logic
| {
    style.fill: transparent
    style.stroke: transparent
  }
}

data: Data Layer {
  class: data

  details: |md
- PostgreSQL (primary store)
- Redis (cache, TTL: 5m)
- S3 (object storage)
| {
    style.fill: transparent
    style.stroke: transparent
  }
}

client -> api: HTTPS
api -> data: read/write
```

---

## Microservices Architecture

```d2
direction: down

vars: {
  d2-config: {
    theme-id: 1
  }
}

classes: {
  service: {
    style: {
      fill: "#e8eaf6"
      stroke: "#3949ab"
      border-radius: 10
      shadow: true
    }
  }
  queue: {
    shape: queue
    style: {
      fill: "#fce4ec"
      stroke: "#c62828"
    }
  }
  db: {
    shape: cylinder
    style: {
      fill: "#e0f2f1"
      stroke: "#00695c"
    }
  }
}

ingress: Load Balancer {
  style: {
    fill: "#fff8e1"
    stroke: "#f57f17"
    double-border: true
  }
}

users-svc: User Service {class: service}
orders-svc: Order Service {class: service}
payments-svc: Payment Service {class: service}
notifications-svc: Notification Service {class: service}

events: Event Bus {class: queue}

users-db: Users DB {class: db}
orders-db: Orders DB {class: db}

ingress -> users-svc
ingress -> orders-svc

users-svc -> users-db
orders-svc -> orders-db
orders-svc -> events: publish order.created
events -> payments-svc: subscribe
events -> notifications-svc: subscribe
payments-svc -> events: publish payment.completed
```

---

## Entity-Relationship Diagram

```d2
direction: right

users: {
  shape: sql_table
  id: int {constraint: primary_key}
  username: varchar(50) {constraint: unique}
  email: varchar(255) {constraint: unique}
  password_hash: varchar(255)
  created_at: timestamp
  updated_at: timestamp
}

posts: {
  shape: sql_table
  id: int {constraint: primary_key}
  author_id: int {constraint: foreign_key}
  title: varchar(255)
  body: text
  status: enum
  published_at: timestamp
  created_at: timestamp
}

comments: {
  shape: sql_table
  id: int {constraint: primary_key}
  post_id: int {constraint: foreign_key}
  author_id: int {constraint: foreign_key}
  body: text
  created_at: timestamp
}

tags: {
  shape: sql_table
  id: int {constraint: primary_key}
  name: varchar(100) {constraint: unique}
}

post_tags: {
  shape: sql_table
  post_id: int {constraint: [primary_key; foreign_key]}
  tag_id: int {constraint: [primary_key; foreign_key]}
}

users.id <-> posts.author_id: writes {
  source-arrowhead.label: 1
  target-arrowhead.label: "*"
}
users.id <-> comments.author_id: writes {
  source-arrowhead.label: 1
  target-arrowhead.label: "*"
}
posts.id <-> comments.post_id: has {
  source-arrowhead.label: 1
  target-arrowhead.label: "*"
}
posts.id <-> post_tags.post_id
tags.id <-> post_tags.tag_id
```

---

## Sequence Diagram - API Flow

```d2
shape: sequence_diagram

client: Browser
gateway: API Gateway
auth: Auth Service
api: Core API
db: Database {
  shape: cylinder
}
cache: Redis {
  shape: cylinder
}

client -> gateway: POST /api/orders
gateway -> auth: Validate JWT
auth -> gateway: 200 OK (valid)

gateway -> api: Forward request

api -> cache: Check inventory cache
cache -> api: Cache miss

api -> db: SELECT inventory
db -> api: Inventory data

api -> cache: Set cache (TTL: 5m)

api -> db: INSERT order
db -> api: Order created

api -> gateway: 201 Created
gateway -> client: 201 Created {order_id: 123}
```

---

## Network Topology

```d2
direction: down

internet: Internet {
  shape: cloud
  style.fill: "#e3f2fd"
}

dmz: DMZ {
  style: {
    fill: "#fff3e0"
    stroke: "#e65100"
    stroke-dash: 3
  }
  fw: Firewall {
    shape: hexagon
    style.fill: "#ffcdd2"
  }
  lb: Load Balancer {
    style.double-border: true
  }
}

private: Private Network {
  style: {
    fill: "#e8f5e9"
    stroke: "#2e7d32"
    stroke-dash: 3
  }
  
  web: Web Tier {
    web1: Web Server 1
    web2: Web Server 2
    web3: Web Server 3
  }
  
  app: App Tier {
    app1: App Server 1
    app2: App Server 2
  }
  
  data: Data Tier {
    primary: Primary DB {shape: cylinder}
    replica: Read Replica {shape: cylinder}
    primary -> replica: replication {style.stroke-dash: 3}
  }
}

internet -> dmz.fw: HTTPS (443)
dmz.fw -> dmz.lb
dmz.lb -> private.web.web1
dmz.lb -> private.web.web2
dmz.lb -> private.web.web3
private.web.web1 -> private.app.app1
private.web.web2 -> private.app.app1
private.web.web3 -> private.app.app2
private.app.app1 -> private.data.primary
private.app.app2 -> private.data.primary
private.app.app1 -> private.data.replica: read queries
private.app.app2 -> private.data.replica: read queries
```

---

## CI/CD Pipeline

```d2
direction: right  # Horizontal is intentional for pipelines/timelines

classes: {
  stage: {
    style: {
      fill: "#e8eaf6"
      border-radius: 10
      shadow: true
    }
  }
  pass: {
    style: {
      stroke: "#4caf50"
      stroke-width: 3
    }
  }
  tool: {
    style: {
      fill: "#f5f5f5"
      font-size: 13
    }
  }
}

commit: Git Push {
  shape: hexagon
  style.fill: "#fff3e0"
}

build: Build Stage {
  class: stage
  lint: Lint {class: tool}
  compile: Compile {class: tool}
  unit: Unit Tests {class: tool}
  lint -> compile -> unit
}

test: Test Stage {
  class: stage
  integration: Integration Tests {class: tool}
  e2e: E2E Tests {class: tool}
  security: Security Scan {class: tool}
  integration -> e2e
  integration -> security
}

deploy-staging: Deploy Staging {
  class: stage
  terraform: Terraform Plan {class: tool}
  apply: Terraform Apply {class: tool}
  smoke: Smoke Tests {class: tool}
  terraform -> apply -> smoke
}

approve: Manual Approval {
  shape: diamond
  style.fill: "#fff9c4"
}

deploy-prod: Deploy Production {
  class: stage
  blue-green: Blue/Green Deploy {class: tool}
  healthcheck: Health Check {class: tool}
  blue-green -> healthcheck
}

commit -> build: trigger {class: pass}
build -> test: artifacts {class: pass}
test -> deploy-staging: passed {class: pass}
deploy-staging -> approve
approve -> deploy-prod: approved
```

---

## Class Hierarchy

```d2
direction: down

classes: {
  abstract: {
    style: {
      fill: "#f3e5f5"
      stroke: "#7b1fa2"
      font-color: "#4a148c"
      italic: true
    }
  }
  interface: {
    style: {
      fill: "#e0f7fa"
      stroke: "#00838f"
      stroke-dash: 3
    }
  }
  concrete: {
    style: {
      fill: "#e8f5e9"
      stroke: "#2e7d32"
    }
  }
}

Serializable: {
  shape: class
  class: interface
  +serialize(): bytes
  +deserialize(data bytes): void
}

Animal: {
  shape: class
  class: abstract
  #name: string
  #age: int
  +getName(): string
  +getAge(): int
  +speak(): string
}

Dog: {
  shape: class
  class: concrete
  -breed: string
  +speak(): string
  +fetch(): void
}

Cat: {
  shape: class
  class: concrete
  -indoor: bool
  +speak(): string
  +purr(): void
}

GuideDog: {
  shape: class
  class: concrete
  -handler: string
  +guide(): void
}

Animal -> Dog: extends {
  target-arrowhead.shape: triangle
  style.stroke-dash: 0
}
Animal -> Cat: extends {
  target-arrowhead.shape: triangle
  style.stroke-dash: 0
}
Dog -> GuideDog: extends {
  target-arrowhead.shape: triangle
  style.stroke-dash: 0
}
Serializable -> Animal: implements {
  style.stroke-dash: 3
  target-arrowhead.shape: triangle
  target-arrowhead.style.filled: false
}
```

---

## State Machine

```d2
direction: right

classes: {
  state: {
    style: {
      fill: "#e8eaf6"
      stroke: "#3949ab"
      border-radius: 12
    }
  }
  terminal: {
    shape: circle
    style: {
      fill: "#263238"
      stroke: "#263238"
      font-color: white
    }
  }
}

start: {
  class: terminal
  label: ""
  width: 30
  height: 30
}

idle: Idle {class: state}
loading: Loading {class: state}
loaded: Loaded {class: state}
error: Error {
  class: state
  style.fill: "#ffebee"
  style.stroke: "#c62828"
}
end: {
  class: terminal
  label: ""
  width: 30
  height: 30
  style.double-border: true
}

start -> idle: init
idle -> loading: fetch()
loading -> loaded: success
loading -> error: failure
error -> idle: retry
loaded -> idle: reset
loaded -> end: dispose
error -> end: dispose
```

---

## Dashboard Grid

```d2
dashboard: Monitoring Dashboard {
  grid-rows: 3
  grid-columns: 3
  grid-gap: 8
  
  style: {
    fill: "#1a1a2e"
    stroke: "#333"
    border-radius: 12
  }
  
  cpu: |md
    ## CPU Usage
    **72%**
    Normal
  | {
    style: {
      fill: "#16213e"
      font-color: "#e0e0e0"
      border-radius: 8
    }
  }
  
  memory: |md
    ## Memory
    **8.2 GB / 16 GB**
    Warning
  | {
    style: {
      fill: "#16213e"
      font-color: "#ffb74d"
      border-radius: 8
    }
  }
  
  disk: |md
    ## Disk I/O
    **120 MB/s**
    Normal
  | {
    style: {
      fill: "#16213e"
      font-color: "#e0e0e0"
      border-radius: 8
    }
  }
  
  requests: |md
    ## Requests/sec
    **2,450**
    High
  | {
    style: {
      fill: "#16213e"
      font-color: "#81c784"
      border-radius: 8
    }
  }
  
  errors: |md
    ## Error Rate
    **0.3%**
    Normal
  | {
    style: {
      fill: "#16213e"
      font-color: "#e0e0e0"
      border-radius: 8
    }
  }
  
  latency: |md
    ## P99 Latency
    **245ms**
    Warning
  | {
    style: {
      fill: "#16213e"
      font-color: "#ffb74d"
      border-radius: 8
    }
  }
  
  uptime: |md
    ## Uptime
    **99.97%**
    Healthy
  | {
    style: {
      fill: "#16213e"
      font-color: "#81c784"
      border-radius: 8
    }
  }
  
  deploys: |md
    ## Deploys Today
    **3**
    On Track
  | {
    style: {
      fill: "#16213e"
      font-color: "#e0e0e0"
      border-radius: 8
    }
  }
  
  alerts: |md
    ## Active Alerts
    **1**
    Acknowledged
  | {
    style: {
      fill: "#16213e"
      font-color: "#ffb74d"
      border-radius: 8
    }
  }
}
```

---

## Cloud Infrastructure

```d2
direction: down

vars: {
  aws-icon: https://icons.terrastruct.com/aws%2F_Group%20Icons%2FAWS-Cloud-alt_light-bg.svg
}

aws: AWS {
  icon: https://icons.terrastruct.com/aws%2F_Group%20Icons%2FAWS-Cloud-alt_light-bg.svg
  style.fill: "#f5f5f5"
  
  vpc: VPC 10.0.0.0/16 {
    style: {
      fill: "#e8f5e9"
      stroke: "#2e7d32"
      stroke-dash: 3
    }
    
    public: Public Subnet {
      style.fill: "#c8e6c9"
      alb: Application Load Balancer {
        style.double-border: true
      }
      nat: NAT Gateway
    }
    
    private: Private Subnet {
      style.fill: "#a5d6a7"
      ecs: ECS Cluster {
        svc1: Service A {style.multiple: true}
        svc2: Service B {style.multiple: true}
      }
    }
    
    data: Data Subnet {
      style.fill: "#81c784"
      rds: RDS PostgreSQL {shape: cylinder}
      elasticache: ElastiCache Redis {shape: cylinder}
    }
  }
  
  s3: S3 Bucket {shape: cloud}
  cloudfront: CloudFront CDN {
    style.double-border: true
  }
  route53: Route 53 DNS
}

users: Users {shape: person}

users -> aws.route53: DNS lookup
aws.route53 -> aws.cloudfront
aws.cloudfront -> aws.vpc.public.alb
aws.cloudfront -> aws.s3: static assets
aws.vpc.public.alb -> aws.vpc.private.ecs.svc1
aws.vpc.public.alb -> aws.vpc.private.ecs.svc2
aws.vpc.private.ecs.svc1 -> aws.vpc.data.rds
aws.vpc.private.ecs.svc2 -> aws.vpc.data.rds
aws.vpc.private.ecs.svc1 -> aws.vpc.data.elasticache
aws.vpc.private.ecs -> aws.vpc.public.nat: outbound internet
```

---

## Data Pipeline

```d2
direction: right  # Horizontal is intentional for pipelines

classes: {
  source: {
    style: {
      fill: "#e3f2fd"
      stroke: "#1565c0"
      border-radius: 8
    }
  }
  process: {
    style: {
      fill: "#fff3e0"
      stroke: "#e65100"
      border-radius: 8
    }
  }
  store: {
    shape: cylinder
    style: {
      fill: "#e8f5e9"
      stroke: "#2e7d32"
    }
  }
  output: {
    style: {
      fill: "#f3e5f5"
      stroke: "#7b1fa2"
      border-radius: 8
    }
  }
}

sources: Data Sources {
  api: REST APIs {class: source}
  events: Event Stream {class: source}
  files: File Uploads {class: source}
}

ingest: Ingestion Layer {
  kafka: Kafka {
    class: process
    style.multiple: true
  }
}

process: Processing {
  spark: Spark Jobs {
    class: process
    style.multiple: true
  }
  validate: Validation {class: process}
  transform: Transform {class: process}
  
  spark -> validate -> transform
}

storage: Storage {
  raw: Raw Data Lake {class: store}
  processed: Processed Store {class: store}
  warehouse: Data Warehouse {class: store}
  
  raw -> processed: ETL
  processed -> warehouse: aggregate
}

output: Consumers {
  dashboard: Analytics Dashboard {class: output}
  ml: ML Pipeline {class: output}
  reports: Reports {class: output}
}

sources.api -> ingest.kafka
sources.events -> ingest.kafka
sources.files -> ingest.kafka
ingest.kafka -> process.spark
ingest.kafka -> storage.raw: raw backup
process.transform -> storage.processed
storage.warehouse -> output.dashboard
storage.warehouse -> output.reports
storage.processed -> output.ml
```

---

## Decision Tree

```d2
direction: down

classes: {
  decision: {
    shape: diamond
    style: {
      fill: "#fff9c4"
      stroke: "#f57f17"
    }
  }
  action: {
    style: {
      fill: "#e8f5e9"
      stroke: "#2e7d32"
      border-radius: 8
    }
  }
  terminal: {
    style: {
      fill: "#e3f2fd"
      stroke: "#1565c0"
      border-radius: 12
      shadow: true
    }
  }
}

start: New Feature Request {
  shape: oval
  style.fill: "#f3e5f5"
}

security: Security Impact? {class: decision}
breaking: Breaking Change? {class: decision}
scope: Scope Size? {class: decision}

review-security: Security Review {class: action}
rfc: Write RFC {class: action}
pr: Open Pull Request {class: action}
design: Design Review {class: action}

fast-track: Fast Track Merge {class: terminal}
standard: Standard Review Process {class: terminal}
committee: Architecture Committee {class: terminal}

start -> security
security -> review-security: Yes
security -> breaking: No
review-security -> committee: Critical

breaking -> rfc: Yes
breaking -> scope: No
rfc -> committee

scope -> design: Large
scope -> pr: Small
design -> standard
pr -> fast-track
```
