# Azure Cloud Architecture

Enterprise-grade 3-tier cloud infrastructure deployed on Microsoft Azure, designed to meet NOS TECDT90341 standards for cloud architecture solutions.

## Table of Contents

- [Overview](#overview)
- [High-Level Architecture](#high-level-architecture)
- [Network Topology](#network-topology)
- [Data Flow](#data-flow)
- [Storage Architecture](#storage-architecture)
- [Security Architecture](#security-architecture)
- [Deployed Resources](#deployed-resources)
- [Access Information](#access-information)

---

## Overview

### Deployment Summary

| Property | Value |
|----------|-------|
| **Region** | Sweden Central |
| **Resource Group** | rg-cloudarch-dev-swc-001 |
| **Architecture** | 3-Tier (Web, App, Data) |
| **IaC Tool** | Terraform |
| **OS** | Ubuntu 22.04 LTS |

### Architecture Principles

| Principle | Implementation |
|-----------|----------------|
| Scalability | Load Balancer + Availability Sets |
| Security | Defense-in-depth with NSGs, Key Vault |
| Reliability | Multi-zone capable, automated backups |
| Cost Optimization | Right-sized VMs, lifecycle policies |
| Observability | Centralized logging with Log Analytics |

---

## High-Level Architecture

### System Diagram

```mermaid
flowchart TB
    subgraph INTERNET
        Users([Users])
    end

    subgraph AZURE["AZURE - SWEDEN CENTRAL"]
        subgraph RG[Resource Group]

            subgraph SECURITY[Security and Monitoring]
                KV[(Key Vault)]
                LA[(Log Analytics)]
                MON[Azure Monitor]
            end

            subgraph VNET[Virtual Network - 10.0.0.0/16]

                subgraph WEB[Web Tier - 10.0.1.0/24]
                    LB{{Load Balancer}}
                    WEBVM[Web VM - Nginx]
                end

                subgraph APP[App Tier - 10.0.2.0/24]
                    APPVM[App VM - Python]
                end

                subgraph DATA[Data Tier - 10.0.3.0/24]
                    SQL[(SQL Database)]
                    BLOB[(Blob Storage)]
                end

            end
        end
    end

    Users -->|HTTPS 443| LB
    LB -->|HTTP 80| WEBVM
    WEBVM -->|TCP 8080| APPVM
    APPVM -->|TCP 1433| SQL
    APPVM -->|HTTPS 443| BLOB

    WEBVM -.->|logs| LA
    APPVM -.->|logs| LA
    SQL -.->|logs| LA
    LA --> MON

    WEBVM -.->|secrets| KV
    APPVM -.->|secrets| KV

    style INTERNET fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#000
    style AZURE fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px,color:#000
    style SECURITY fill:#FFEBEE,stroke:#C62828,stroke-width:2px,color:#000
    style VNET fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px,color:#000
    style WEB fill:#E1F5FE,stroke:#0277BD,stroke-width:1px,color:#000
    style APP fill:#FFF3E0,stroke:#EF6C00,stroke-width:1px,color:#000
    style DATA fill:#F1F8E9,stroke:#558B2F,stroke-width:1px,color:#000
```

### Component Summary

| Component | Azure Service | Specification | Purpose |
|-----------|--------------|---------------|---------|
| Load Balancer | Standard SKU | Zone-redundant | Traffic distribution |
| Web VM | Standard_B2s_v2 | 2 vCPU, 8 GB | Nginx reverse proxy |
| App VM | Standard_B2s_v2 | 2 vCPU, 8 GB | Python application |
| SQL Database | Basic DTU | TDE encryption | Relational data |
| Blob Storage | Standard LRS | Lifecycle policies | Unstructured data |
| Key Vault | Standard | RBAC enabled | Secrets management |
| Log Analytics | Per-GB | 30-day retention | Centralized logging |

### Traffic Flow

```
REQUEST FLOW
============

[User] --HTTPS--> [Load Balancer] --HTTP--> [Web VM] --API--> [App VM] --SQL--> [Database]
                                                                  |
                                                                  +--HTTPS--> [Blob Storage]
```

### Security Layers

| Layer | Controls | Implementation |
|-------|----------|----------------|
| Perimeter | DDoS, WAF-ready | Load Balancer |
| Network | Micro-segmentation | NSGs per subnet |
| Identity | Zero-trust | Managed identities |
| Data | Encryption | TDE, AES-256 |
| Monitoring | Detection | Log Analytics |

---

## Network Topology

### Network Diagram

```mermaid
flowchart TB
    subgraph INTERNET
        USERS([External Users])
        ADMIN([Administrators])
    end

    subgraph AZURE["AZURE - SWEDEN CENTRAL"]
        PIP[Public IP]

        subgraph VNET[VNET - 10.0.0.0/16]

            subgraph WEBSUB[Web Subnet - 10.0.1.0/24]
                NSG1{{NSG-Web}}
                LB[Load Balancer]
                VM1[vm-web]
            end

            subgraph APPSUB[App Subnet - 10.0.2.0/24]
                NSG2{{NSG-App}}
                VM2[vm-app]
            end

            subgraph DATASUB[Data Subnet - 10.0.3.0/24]
                NSG3{{NSG-Data}}
                SQLEP[SQL Endpoint]
                STOREP[Storage Endpoint]
            end

            subgraph MGMTSUB[Mgmt Subnet - 10.0.4.0/24]
                NSG4{{NSG-Mgmt}}
                BASTION[Bastion Host]
            end

        end

        SQLSRV[(SQL Server)]
        STORAGE[(Storage Account)]
    end

    USERS -->|443| PIP
    PIP --> LB
    LB -->|80| VM1
    VM1 -->|8080| VM2
    VM2 -->|1433| SQLEP
    VM2 -->|443| STOREP
    SQLEP -.-> SQLSRV
    STOREP -.-> STORAGE
    ADMIN -->|443| BASTION
    BASTION -->|22| VM1
    BASTION -->|22| VM2

    style INTERNET fill:#ECEFF1,stroke:#546E7A,stroke-width:2px,color:#000
    style AZURE fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#000
    style VNET fill:#FFFFFF,stroke:#424242,stroke-width:2px,color:#000
    style WEBSUB fill:#C8E6C9,stroke:#388E3C,stroke-width:1px,color:#000
    style APPSUB fill:#FFE0B2,stroke:#F57C00,stroke-width:1px,color:#000
    style DATASUB fill:#F8BBD9,stroke:#C2185B,stroke-width:1px,color:#000
    style MGMTSUB fill:#E1BEE7,stroke:#7B1FA2,stroke-width:1px,color:#000
```

### IP Address Allocation

| Resource | CIDR | IPs | Purpose |
|----------|------|-----|---------|
| VNet | 10.0.0.0/16 | 65,534 | Main network |
| Web Subnet | 10.0.1.0/24 | 251 | Web tier |
| App Subnet | 10.0.2.0/24 | 251 | App tier |
| Data Subnet | 10.0.3.0/24 | 251 | Data tier |
| Mgmt Subnet | 10.0.4.0/24 | 251 | Management |

### Azure Reserved Addresses (per subnet)

| Address | Purpose |
|---------|---------|
| x.x.x.0 | Network |
| x.x.x.1 | Gateway |
| x.x.x.2 | DNS Primary |
| x.x.x.3 | DNS Secondary |
| x.x.x.255 | Broadcast |

### Network Security Groups

#### NSG-Web

| Priority | Name | Direction | Source | Port | Action |
|----------|------|-----------|--------|------|--------|
| 100 | Allow-HTTP | Inbound | Internet | 80 | Allow |
| 110 | Allow-HTTPS | Inbound | Internet | 443 | Allow |
| 120 | Allow-LB | Inbound | AzureLB | * | Allow |
| 150 | Allow-SSH | Inbound | Internet | 22 | Allow |
| 4096 | Deny-All | Inbound | * | * | Deny |

#### NSG-App

| Priority | Name | Direction | Source | Port | Action |
|----------|------|-----------|--------|------|--------|
| 100 | Allow-Web | Inbound | 10.0.1.0/24 | 8080 | Allow |
| 150 | Allow-SSH | Inbound | Internet | 22 | Allow |
| 4096 | Deny-All | Inbound | * | * | Deny |

#### NSG-Data

| Priority | Name | Direction | Source | Port | Action |
|----------|------|-----------|--------|------|--------|
| 100 | Allow-SQL | Inbound | 10.0.2.0/24 | 1433 | Allow |
| 110 | Allow-Storage | Inbound | 10.0.2.0/24 | 443 | Allow |
| 4096 | Deny-All | Inbound | * | * | Deny |

### Connectivity Matrix

| Source | Destination | Protocol | Port | Status |
|--------|-------------|----------|------|--------|
| Internet | Load Balancer | HTTPS | 443 | **Allowed** |
| Load Balancer | Web VMs | HTTP | 80 | **Allowed** |
| Web Subnet | App Subnet | TCP | 8080 | **Allowed** |
| App Subnet | Data Subnet | TCP | 1433 | **Allowed** |
| App Subnet | Storage | HTTPS | 443 | **Allowed** |
| Internet | VMs (NAT) | SSH | 22/2222 | **Allowed** |
| Any | Any | Any | Any | **Denied** |

---

## Data Flow

### Application Data Flow

```mermaid
flowchart LR
    subgraph CLIENT
        USER([User])
    end

    subgraph WEBTIER[Web Tier]
        LB{{LB}}
        WEB[Web Server]
    end

    subgraph APPTIER[App Tier]
        APP[App Server]
        CACHE[(Cache)]
    end

    subgraph DATATIER[Data Tier]
        DB[(SQL)]
        BL[(Blob)]
    end

    subgraph SEC[Security]
        KV[(Key Vault)]
    end

    USER -->|1| LB
    LB -->|2| WEB
    WEB -->|3| APP
    APP <-->|4| CACHE
    APP <-->|5| DB
    APP <-->|6| BL
    APP <-->|7| KV

    style CLIENT fill:#ECEFF1,stroke:#546E7A,color:#000
    style WEBTIER fill:#E3F2FD,stroke:#1565C0,color:#000
    style APPTIER fill:#FFF3E0,stroke:#EF6C00,color:#000
    style DATATIER fill:#E8F5E9,stroke:#2E7D32,color:#000
    style SEC fill:#FCE4EC,stroke:#C2185B,color:#000
```

### Request-Response Sequence

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant LB as Load Balancer
    participant W as Web Server
    participant A as App Server
    participant D as Database

    C->>+LB: HTTPS Request
    LB->>+W: Forward HTTP
    W->>W: Validate Input
    W->>+A: API Call
    A->>+D: Query Data
    D-->>-A: Return Results
    A-->>-W: JSON Response
    W-->>-LB: HTTP Response
    LB-->>-C: HTTPS Response

    Note over C,D: Typical latency 50-200ms
```

### Data Classification

| Data Type | Classification | Location | Encryption | Retention |
|-----------|---------------|----------|------------|-----------|
| Credentials | Confidential | Key Vault | AES-256 | Indefinite |
| App Data | Internal | SQL Database | TDE | 7 years |
| Sessions | Transient | Memory | N/A | Session |
| Audit Logs | Compliance | Log Analytics | Platform | 2 years |
| Files | Internal | Blob Storage | AES-256 | 1 year |
| Backups | Confidential | GRS Storage | AES-256 | 30 days |

---

## Storage Architecture

### SQL Database Schema

```mermaid
erDiagram
    USERS ||--o{ ORDERS : places
    USERS {
        int id PK
        string email UK
        string password_hash
        datetime created_at
    }
    ORDERS ||--|{ ORDER_ITEMS : contains
    ORDERS {
        int id PK
        int user_id FK
        decimal total
        datetime order_date
    }
    ORDER_ITEMS {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
    }
    PRODUCTS ||--o{ ORDER_ITEMS : includes
    PRODUCTS {
        int id PK
        string name
        decimal price
        string image_url
    }
```

### Blob Storage Structure

```
storage-account/
├── uploads/
│   ├── images/
│   │   └── {year}/{month}/{guid}.jpg
│   └── documents/
│       └── {year}/{month}/{guid}.pdf
├── backups/
│   ├── database/
│   │   └── {date}/backup.bacpac
│   └── config/
│       └── {date}/config.json
└── logs/
    └── archive/
        └── {year}/{month}/logs.gz
```

### Data Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Hot : Created
    Hot --> Cool : 30 days inactive
    Cool --> Archive : 90 days inactive
    Archive --> Deleted : Retention expired
    Deleted --> [*]

    Hot --> Deleted : User request
    Cool --> Hot : Data accessed
    Archive --> Cool : Data restored
```

| Tier | Access | Cost | Trigger |
|------|--------|------|---------|
| Hot | Frequent | $$$ | Default |
| Cool | Monthly | $$ | 30 days |
| Archive | Yearly | $ | 90 days |
| Delete | N/A | - | Expired |

---

## Security Architecture

### Encryption at Rest

```mermaid
flowchart LR
    subgraph APPLICATION
        DATA[Plain Data]
    end

    subgraph ENCRYPTION
        AES[AES-256]
    end

    subgraph KEYS[Key Management]
        KEK[KEK - Azure Managed]
        DEK[DEK - Data Key]
    end

    subgraph STORAGE
        ENCRYPTED[Encrypted Data]
    end

    DATA --> AES
    AES --> ENCRYPTED
    KEK --> DEK
    DEK --> AES

    style ENCRYPTION fill:#FCE4EC,stroke:#C2185B,color:#000
    style KEYS fill:#FFF3E0,stroke:#EF6C00,color:#000
```

### Encryption in Transit

| Source | Destination | Protocol | Certificate |
|--------|-------------|----------|-------------|
| User | Load Balancer | TLS 1.2+ | Azure Managed |
| LB | Web Server | HTTP | Internal |
| Web | App Server | HTTPS | Self-signed |
| App | SQL Database | TLS 1.2 | Azure Managed |
| App | Blob Storage | HTTPS | Azure Managed |

### Backup Strategy

```mermaid
flowchart TB
    subgraph SOURCES[Data Sources]
        VM[VM Disks]
        SQL[SQL DB]
        BLOB[Blob Storage]
    end

    subgraph BACKUP[Backup Service]
        VAULT[Recovery Services Vault]
        POLICY[Backup Policy]
    end

    subgraph TARGET[Backup Storage]
        LRS[LRS - Dev]
        GRS[GRS - Prod]
    end

    VM -->|Daily| VAULT
    SQL -->|Continuous| VAULT
    BLOB -->|Soft Delete| BLOB

    POLICY --> VAULT
    VAULT --> LRS
    VAULT --> GRS

    style BACKUP fill:#E8F5E9,stroke:#2E7D32,color:#000
```

| Resource | Frequency | Retention | Type |
|----------|-----------|-----------|------|
| VM Disks | Daily | 7 days | Incremental |
| SQL Database | Continuous | 7-35 days | Point-in-time |
| Blob Storage | N/A | 7 days | Soft delete |
| Key Vault | Automatic | 90 days | Soft delete |

---

## Deployed Resources

### Current Resources (19 total)

| Type | Name | Status |
|------|------|--------|
| Resource Group | rg-cloudarch-dev-swc-001 | Active |
| Virtual Network | vnet-cloudarch-dev-swc-001 | Active |
| Subnet (Web) | snet-web-dev-001 | Active |
| Subnet (App) | snet-app-dev-001 | Active |
| Subnet (Data) | snet-data-dev-001 | Active |
| Subnet (Mgmt) | AzureBastionSubnet | Active |
| NSG (Web) | nsg-web-dev-swc-001 | Active |
| NSG (App) | nsg-app-dev-swc-001 | Active |
| NSG (Data) | nsg-data-dev-swc-001 | Active |
| Load Balancer | lb-cloudarch-dev-swc-001 | Active |
| Public IP | pip-lb-cloudarch-dev-swc-001 | Active |
| Availability Set | avset-web-dev-swc-001 | Active |
| VM (Web) | vm-web-dev-swc-001 | Running |
| VM (App) | vm-app-dev-swc-001 | Running |
| SQL Server | sql-cloudarch-dev-swc-001 | Active |
| SQL Database | sqldb-cloudarch-dev-001 | Active |
| Storage Account | stcloudarchdev* | Active |
| Key Vault | kv-cloudarch-dev-* | Active |
| Log Analytics | log-cloudarch-dev-swc-001 | Active |

### Service Endpoints

| Service | Endpoint |
|---------|----------|
| Web Application | `http://<public-ip>` |
| SQL Server | `sql-cloudarch-dev-swc-001.database.windows.net` |
| Key Vault | `https://kv-cloudarch-dev-*.vault.azure.net/` |
| Storage | `https://stcloudarchdev*.blob.core.windows.net/` |

---

## Access Information

### SSH Access via Load Balancer NAT

| VM | Command |
|----|---------|
| Web VM | `ssh azureadmin@<public-ip>` |
| App VM | `ssh -p 2222 azureadmin@<public-ip>` |

### Verified Services

| VM | Service | Version | Status |
|----|---------|---------|--------|
| vm-web-dev-swc-001 | Nginx | 1.18.0 | Running |
| vm-app-dev-swc-001 | Python | 3.10.12 | Installed |
| Load Balancer | HTTP | - | 200 OK |

### Azure CLI Verification

```bash
# List all resources
az resource list --resource-group rg-cloudarch-dev-swc-001 --output table

# Check VM status
az vm list --resource-group rg-cloudarch-dev-swc-001 --show-details --output table

# Test web endpoint
curl -s -o /dev/null -w "%{http_code}" http://<public-ip>
```

---

## Document Information

| Property | Value |
|----------|-------|
| Author | Mohammad Othman |
| Standard | NOS TECDT90341 |
| Last Updated | January 2026 |
| Terraform | >= 1.0 |
| Provider | azurerm 3.x |
