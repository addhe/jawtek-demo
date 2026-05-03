# 🤖 Jawtek Demo — AI Generative Prompts for DevOps

> Contoh demo prompt AI generative untuk workflow DevOps. Setiap prompt dirancang untuk mengotomasi tugas-tugas DevOps sehari-hari.

---

## 📋 Daftar Prompt

### 1. Infrastructure Provisioning

**Prompt:**
```
Buatkan terraform module untuk GKE cluster di GCP dengan spesifikasi berikut:
- Region: asia-southeast2
- Cluster type: Standard (bukan Autopilot)
- Node pool: e2-medium, preemptible, 1-3 nodes auto-scaling
- Network: custom VPC dengan subnet 10.20.0.0/24
- Enable workload identity
- Tambahkan variable untuk conditional autopilot (staging=false, production=true)
```

**Use Case:** Provisioning infrastructure GCP yang repeatable dan cost-optimized.

---

### 2. Kubernetes Manifest Generation

**Prompt:**
```
Buatkan Kubernetes deployment manifest untuk aplikasi web dengan:
- 3 replicas dengan anti-affinity rule
- Liveness probe di /health (port 8080, delay 30s)
- Readiness probe di /ready (port 8080, delay 5s)
- Resource limits: memory 512Mi, cpu 1000m
- Resource requests: memory 128Mi, cpu 100m
- PVC 5Gi untuk data persistence (storageClass: standard)
- ConfigMap untuk environment variables
- Secret untuk database credentials
- HorizontalPodAutoscaler (1-10 replicas, target CPU 70%)
```

**Use Case:** Generate K8s manifests yang production-ready dengan best practices.

---

### 3. CI/CD Pipeline

**Prompt:**
```
Buatkan Cloud Build pipeline (cloudbuild.yaml) untuk:
- Build Docker image dari Dockerfile di ./docker/app
- Push ke Artifact Registry dengan 3 tags: $SHORT_SHA, latest, dan $VERSION
- Deploy ke GKE staging namespace jika branch = main
- Deploy ke GKE production namespace jika tag = v*
- Tambahkan step untuk run database migration sebelum deploy
- Tambahkan step untuk smoke test setelah deploy
- Slack notification untuk build success/failure
```

**Use Case:** CI/CD pipeline end-to-end dari build sampai deploy.

---

### 4. Monitoring & Alerting

**Prompt:**
```
Buatkan Prometheus alerting rules untuk:
- Pod CrashLoopBackOff (>5 restart dalam 10 menit)
- Node NotReady (>3 menit)
- Memory usage >85% (warning) dan >95% (critical)
- CPU usage >80% (warning) dan >95% (critical)
- PVC usage >80% (warning) dan >95% (critical)
- HTTP 5xx error rate >5% (warning) dan >10% (critical)
- Pod pending >5 menit (resource exhaustion)

Tambahan:
- Buatkan Grafana dashboard JSON untuk visualisasi metrics di atas
- Buatkan PagerDuty notification config untuk critical alerts
```

**Use Case:** Monitoring setup yang komprehensif untuk production K8s.

---

### 5. Incident Response & Debugging

**Prompt:**
```
Pod <app-name> di namespace <namespace> statusnya CrashLoopBackOff. 
Pod restart sudah 15 kali dalam 30 menit terakhir.
Last log: "FATAL: connection to server at '<db-service>:5432' failed"

Cluster: <cluster-name> (GKE, asia-southeast2-a)
Namespace: <namespace>
Service: <app-name> (LoadBalancer, port <port>)

Tolong:
1. Identifikasi root cause
2. Berikan langkah debugging step-by-step
3. Buatkan kubectl commands untuk investigate
4. Sarankan fix dan preventive measures
```

**Use Case:** Quick incident response dengan AI-assisted debugging.

---

### 6. Security Hardening

**Prompt:**
```
Buatkan Kubernetes security hardening checklist dan manifest untuk:
- NetworkPolicy yang restrict semua egress kecuali:
  - DNS (UDP port 53)
  - Database internal (TCP port 5432)
  - External HTTPS (TCP port 443)
- PodSecurityPolicy/SecurityContext:
  - runAsNonRoot: true
  - readOnlyRootFilesystem: true
  - drop all capabilities
  - seccompProfile: RuntimeDefault
- RBAC: minimal permissions untuk service account
- Secret encryption at rest
- Image pull dari private registry only
- Tambahkan juga OPA/Gatekeeper constraint template
```

**Use Case:** Security hardening untuk K8s cluster yang akan go-live.

---

### 7. Cost Optimization

**Prompt:**
```
Analisa dan optimasi biaya GCP infrastructure berikut:
- GKE cluster: $260/bulan (Autopilot, 3 nodes)
- Cloud SQL: $15/bulan (db-f1-micro)
- Persistent disks: $20/bulan (300GB total)
- Network egress: $10/bulan
- Total: ~$305/bulan

Target: kurangi 50% tanpa mengurangi availability.

Buatkan:
1. Analisa cost per service
2. Rekomendasi optimasi per item
3. Terraform changes yang diperlukan
4. Risk assessment untuk setiap perubahan
5. Timeline implementasi
```

**Use Case:** Cost optimization review untuk management reporting.

---

### 8. Disaster Recovery

**Prompt:**
```
Buatkan Disaster Recovery Plan untuk GKE cluster dengan:
- RPO: 1 jam, RTO: 4 jam
- Services: <web-app>, <database>, <cache>
- Region: asia-southeast2 (primary), asia-southeast1 (DR)

Include:
1. Backup strategy (database, config, secrets)
2. Failover procedure step-by-step
3. DNS cutover automation
4. Data replication strategy
5. Runbook untuk setiap scenario:
   - Single pod failure
   - Node failure
   - Zone failure
   - Region failure
6. Testing schedule (quarterly DR drill)
7. Terraform code untuk DR infrastructure
```

**Use Case:** DR planning untuk compliance dan business continuity.

---

### 9. Terraform State Recovery

**Prompt:**
```
Terraform state lock terjadi di GCS bucket. Error message:
"Error acquiring the state lock: conditional precondition failed"

Saya sudah coba terragrunt force-unlock <lock-id> tapi masih gagal.

Berikan:
1. Langkah-langkah untuk force unlock state
2. Cara mencegah state lock di masa depan
3. Best practices untuk state management
4. Script untuk detect dan auto-resolve stale locks
```

**Use Case:** Troubleshooting Terraform state issues yang sering terjadi.

---

### 10. Multi-Environment Deployment

**Prompt:**
```
Buatkan Terragrunt configuration untuk multi-environment deployment:
- 3 environments: dev, staging, production
- Shared modules: VPC, GKE, Cloud SQL, IAM
- Environment-specific variables:
  - dev: 1 node, preemptible, no HA
  - staging: 2 nodes, preemptible, single-zone
  - production: 3+ nodes, on-demand, multi-zone
- Separate state files per environment
- Cost estimation per environment
- Promotion workflow: dev -> staging -> production
```

**Use Case:** Setup multi-environment infrastructure yang konsisten dan scalable.

---

## 💡 Tips Menggunakan Prompt

1. **Sesuaikan parameter** — Ganti region, size, nama sesuai kebutuhan
2. **Iterasi** — AI mungkin perlu di-refine, jangan langsung copy-paste ke production
3. **Review** — Selalu review output sebelum apply ke infrastructure
4. **Version control** — Simpan prompt dan output di Git untuk audit trail
5. **Test di staging** — Jangan test langsung di production

---

## 🔗 Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Google Cloud Build](https://cloud.google.com/build/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)

---

*Generated by Skynet-Coder | Jawtek Demo*
