# Cloud Architecture Design Decisions

## Executive Summary

This document outlines the architectural decisions for a production-grade, multi-tier cloud solution deployed on Microsoft Azure. The architecture follows the Microsoft Azure Well-Architected Framework principles: reliability, security, cost optimisation, operational excellence, and performance efficiency.

## Business Requirements Analysis

### Organisational Context

The solution addresses typical enterprise requirements for a scalable, secure, and cost-effective cloud infrastructure:

| Requirement | Priority | Solution Approach |
|-------------|----------|-------------------|
| High Availability | Critical | Multi-zone deployment, load balancing |
| Security | Critical | Defence-in-depth, Zero Trust principles |
| Scalability | High | Auto-scaling, modular architecture |
| Cost Efficiency | High | Right-sizing, resource optimisation |
| Compliance | High | Encryption, audit logging, RBAC |
| Disaster Recovery | Medium | Geo-redundant storage, backup policies |

### Stakeholder Requirements

- **Operations Team**: Automated deployments, centralised monitoring, clear runbooks
- **Security Team**: Encryption at rest/transit, network segmentation, audit trails
- **Development Team**: Consistent environments, infrastructure as code, self-service capabilities
- **Finance Team**: Predictable costs, resource tagging for chargeback

## Technology Selection Rationale

### Cloud Platform: Microsoft Azure

**Selection Criteria:**
- Enterprise-grade SLAs (99.95%+ availability)
- Comprehensive compliance certifications (ISO 27001, SOC 2, GDPR)
- Native integration with existing Microsoft technologies
- Mature Infrastructure as Code support via Terraform

### Infrastructure as Code: Terraform

**Why Terraform over ARM Templates or Bicep:**

| Factor | Terraform | ARM/Bicep |
|--------|-----------|-----------|
| Multi-cloud | Yes | Azure only |
| State Management | Built-in | External |
| Module Ecosystem | Extensive | Limited |
| Learning Curve | Moderate | Steep |
| Community Support | Large | Growing |

**Decision:** Terraform provides superior modularity, state management, and transferable skills across cloud platforms.

### Compute: Azure Virtual Machines with Availability Zones

**Rationale:**
- Full control over OS and runtime environment
- Availability Zones provide 99.99% SLA
- Supports custom security hardening
- Flexible scaling options

**Alternative Considered:** Azure App Service
- Rejected for this use case due to limited OS-level access requirements

### Database: Azure SQL Database

**Rationale:**
- Fully managed PaaS reduces operational overhead
- Built-in high availability with zone redundancy
- Automated backups with point-in-time restore
- Advanced threat protection included

### Storage: Azure Blob Storage with Lifecycle Management

**Rationale:**
- Cost-effective tiered storage (Hot, Cool, Archive)
- Lifecycle policies automate data retention
- Immutable storage for compliance requirements
- Integration with Azure CDN for global distribution

## Trade-off Analysis

### Cost vs Performance

| Decision | Cost Impact | Performance Impact | Rationale |
|----------|-------------|-------------------|-----------|
| B2s VM size (Dev) | Low | Adequate | Development workloads don't require high performance |
| Standard_D2s_v3 (Prod) | Medium | High | Production requires consistent performance |
| Basic SQL tier (Dev) | Low | Limited | Cost savings acceptable for non-production |
| Standard SQL tier (Prod) | Medium | High | Production requires DTU guarantees |

### Security vs Usability

| Control | Security Benefit | Usability Impact | Decision |
|---------|-----------------|------------------|----------|
| Azure Bastion | Eliminates public SSH/RDP | Slight latency | Implemented |
| NSG Rules | Network segmentation | Complexity | Implemented with documentation |
| Key Vault | Secrets management | Additional workflow | Implemented - security critical |
| Private Endpoints | No public exposure | Higher cost | Considered for production |

### Reliability vs Cost

| Configuration | Reliability | Monthly Cost | Environment |
|--------------|-------------|--------------|-------------|
| Single zone | 99.9% | Base | Development |
| Multi-zone | 99.99% | +20% | Staging/Production |
| Multi-region | 99.999% | +100% | Future consideration |

## Scalability Considerations

### Horizontal Scaling Strategy

```
                    ┌─────────────────┐
                    │  Azure Load     │
                    │  Balancer       │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
    ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
    │   VM 1      │   │   VM 2      │   │   VM N      │
    │   Zone 1    │   │   Zone 2    │   │   Zone 3    │
    └─────────────┘   └─────────────┘   └─────────────┘
```

**Auto-scaling Configuration:**
- Minimum instances: 2 (for high availability)
- Maximum instances: 10 (cost control)
- Scale-out trigger: CPU > 70% for 5 minutes
- Scale-in trigger: CPU < 30% for 10 minutes
- Cool-down period: 5 minutes

### Vertical Scaling Path

| Stage | VM Size | vCPUs | RAM | Use Case |
|-------|---------|-------|-----|----------|
| Start | B2s | 2 | 4GB | Development |
| Growth | D2s_v3 | 2 | 8GB | Production start |
| Scale | D4s_v3 | 4 | 16GB | Increased load |
| Enterprise | D8s_v3 | 8 | 32GB | High demand |

### Database Scaling

- **Vertical**: DTU/vCore scaling without downtime
- **Horizontal**: Read replicas for reporting workloads
- **Elastic Pools**: Cost-effective multi-tenant scenarios

## Disaster Recovery Strategy

### Recovery Objectives

| Metric | Development | Staging | Production |
|--------|-------------|---------|------------|
| RTO (Recovery Time Objective) | 24 hours | 4 hours | 1 hour |
| RPO (Recovery Point Objective) | 24 hours | 1 hour | 15 minutes |

### Backup Configuration

**Virtual Machines:**
- Azure Backup with daily snapshots
- 30-day retention for production
- 7-day retention for non-production

**Azure SQL Database:**
- Automated backups (full weekly, differential daily, log every 5-10 min)
- Point-in-time restore capability
- Long-term retention: 1 year for compliance

**Storage Accounts:**
- Geo-redundant storage (GRS) for production
- Locally redundant storage (LRS) for development
- Soft delete enabled (14-day retention)

### Recovery Procedures

1. **VM Failure**: Auto-healing via availability set/zone
2. **Zone Failure**: Traffic rerouted to healthy zones
3. **Region Failure**: Manual failover to paired region (future implementation)
4. **Data Corruption**: Point-in-time restore from backup

## Cost Estimation

### Monthly Cost Breakdown (Development Environment)

| Resource | Configuration | Estimated Monthly Cost (GBP) |
|----------|--------------|------------------------------|
| Virtual Machine | B2s (1 instance) | ~£12 |
| Azure SQL Database | Basic tier (5 DTU) | ~£4 |
| Storage Account | LRS, 100GB | ~£2 |
| Virtual Network | Standard | Free |
| Network Security Group | Standard | Free |
| Key Vault | Standard, minimal operations | ~£1 |
| Log Analytics | 5GB ingestion | Free tier |
| **Total (Dev)** | | **~£19/month** |

### Monthly Cost Breakdown (Production Environment)

| Resource | Configuration | Estimated Monthly Cost (GBP) |
|----------|--------------|------------------------------|
| Virtual Machines | D2s_v3 (2 instances) | ~£140 |
| Load Balancer | Standard | ~£18 |
| Azure SQL Database | Standard S1 (20 DTU) | ~£25 |
| Storage Account | GRS, 500GB | ~£20 |
| Key Vault | Standard | ~£3 |
| Azure Bastion | Standard | ~£100 |
| Log Analytics | 10GB ingestion | ~£20 |
| Azure Monitor | Alerts, metrics | ~£10 |
| **Total (Prod)** | | **~£336/month** |

### Cost Optimisation Recommendations

1. **Reserved Instances**: 1-year commitment saves ~40% on VMs
2. **Azure Hybrid Benefit**: Use existing Windows Server licenses
3. **Auto-shutdown**: Development VMs shutdown outside business hours
4. **Storage Tiering**: Move cold data to Cool/Archive tiers
5. **Right-sizing**: Regular review of resource utilisation

## Security Architecture

### Defence in Depth

```
┌─────────────────────────────────────────────────────────┐
│                    Azure DDoS Protection                │
├─────────────────────────────────────────────────────────┤
│                    Network Security Groups              │
├─────────────────────────────────────────────────────────┤
│                    Azure Firewall (Optional)            │
├─────────────────────────────────────────────────────────┤
│                    Application Security                 │
├─────────────────────────────────────────────────────────┤
│                    Data Encryption                      │
└─────────────────────────────────────────────────────────┘
```

### Network Segmentation

| Subnet | CIDR | Purpose | Allowed Inbound |
|--------|------|---------|-----------------|
| Web | 10.0.1.0/24 | Public-facing servers | HTTP/HTTPS from Internet |
| App | 10.0.2.0/24 | Application tier | From Web subnet only |
| Data | 10.0.3.0/24 | Database tier | From App subnet only |
| Management | 10.0.4.0/24 | Bastion, monitoring | Azure Bastion |

### Identity and Access Management

- **Azure Active Directory**: Centralised identity
- **Managed Identities**: VM-to-service authentication
- **RBAC**: Least privilege access model
- **PIM**: Just-in-time admin access (recommended)

### Encryption Standards

| Data State | Encryption Method | Key Management |
|------------|------------------|----------------|
| At Rest | AES-256 | Azure-managed keys (default) |
| In Transit | TLS 1.2+ | Azure-managed certificates |
| In Use | Confidential computing | Future consideration |

## Monitoring and Observability

### Monitoring Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   VMs       │────▶│   Log       │───▶│   Azure     │
│   Apps      │     │   Analytics │     │   Monitor   │
│   Databases │     │   Workspace │     │   Alerts    │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  Dashboards │
                    │  Workbooks  │
                    └─────────────┘
```

### Key Metrics and Alerts

| Metric | Warning Threshold | Critical Threshold | Action |
|--------|-------------------|-------------------|--------|
| CPU Usage | 70% | 90% | Scale out / Investigate |
| Memory Usage | 80% | 95% | Scale up / Investigate |
| Disk Space | 80% | 90% | Expand / Clean up |
| HTTP 5xx Errors | > 1% | > 5% | Investigate |
| Database DTU | 80% | 95% | Scale up |

## Compliance Considerations

### Data Residency

- All resources deployed in Sweden Central region
- Geo-redundant backups within Sweden (Sweden South paired region)
- No data transfer outside Sweden without explicit configuration

### Audit and Logging

- **Activity Logs**: All control plane operations (90-day retention)
- **Diagnostic Logs**: Resource-level logging to Log Analytics
- **Network Logs**: NSG flow logs for security analysis
- **Application Logs**: Centralised in Log Analytics

### Regulatory Alignment

| Regulation | Relevant Controls | Implementation |
|------------|------------------|----------------|
| GDPR | Data encryption, access controls | Key Vault, RBAC, encryption |
| ISO 27001 | Security management | NSGs, monitoring, audit logs |
| Cyber Essentials | Basic security controls | Patching, firewalls, access control |

## Future Enhancements

### Phase 2 Considerations

1. **Container Platform**: Azure Kubernetes Service for microservices
2. **API Management**: Azure API Management for API governance
3. **CDN Integration**: Azure CDN for static content delivery
4. **Multi-region**: Active-passive DR in paired region

### Technical Debt

| Item | Priority | Effort | Business Impact |
|------|----------|--------|-----------------|
| Private Endpoints | Medium | Medium | Enhanced security |
| Azure Policy | Medium | Low | Governance automation |
| Cost Management Alerts | Low | Low | Budget control |

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026 | Mohammad Othman | Initial architecture design |

## Appendices

### A. Reference Architecture

This design follows the Microsoft Azure Well-Architected Framework:
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
- [Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)

### B. Naming Convention

```
<resource-type>-<workload>-<environment>-<region>-<instance>
```

Examples:
- `rg-cloudarch-dev-swc-001` - Resource Group
- `vnet-cloudarch-dev-swc-001` - Virtual Network
- `vm-web-dev-swc-001` - Virtual Machine
- `stcloudarchdevswc001` - Storage Account (no hyphens)

### C. Tagging Strategy

All resources include:
- `Project`: cloud-architecture
- `Environment`: dev/staging/prod
- `Owner`: Mohammad Othman
- `ManagedBy`: Terraform
- `CostCenter`: Learning
