---
domain: Networking Concepts
status: 🔲
tags: [network-plus, cloud]
---

# Cloud Concepts

## Service Models

- **IaaS**: infrastructure (VMs, storage, networking) — most control, most management overhead.
- **PaaS**: platform (runtime, OS managed) — deploy code, provider manages infra.
- **SaaS**: software (fully managed application) — least control, least overhead.

## Deployment Models

- **Public**: shared, multi-tenant (AWS, Azure, GCP).
- **Private**: dedicated to one org.
- **Hybrid**: mix of public + private, often with a VPN/dedicated link between.
- **Community**: shared by orgs with common concerns (e.g., compliance requirements).

## Connectivity

- **VPN**: encrypted tunnel over public internet.
- **Direct Connect / ExpressRoute**: dedicated private link to cloud provider, bypasses public internet.
- **VPC (Virtual Private Cloud)**: isolated network segment within a cloud provider.

## Key Terms

- **Elasticity**: scale resources automatically with demand.
- **Multitenancy**: multiple customers share underlying infrastructure, logically isolated.
- **NFV (Network Functions Virtualization)**: virtualize network services (firewalls, routers) instead of dedicated hardware.

## Common Exam Traps

- IaaS/PaaS/SaaS responsibility split questions are frequent — know who manages what at each layer.
- Direct Connect/ExpressRoute is NOT a VPN — it's a dedicated physical/private circuit.

## Related

- [[Network Topologies]]
