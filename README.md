# Enterprise Integration Architecture: Clean Core PI/PO Migration & Hybrid OData

[![SAP Integration Suite](https://img.shields.io/badge/SAP-Integration%20Suite-0A85EA?logo=sap&logoColor=white)](https://www.sap.com/products/technology-platform/integration-suite.html)
[![S/4HANA](https://img.shields.io/badge/SAP-S%2F4HANA%202023-F0AB00?logo=sap&logoColor=black)](https://www.sap.com/products/erp/s4hana.html)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Core%20%7C%20Zero%20Modification-success)](#architecture-overview)
[![Security](https://img.shields.io/badge/Security-Principal%20Propagation%20(X.509)-red)](#security--identity-propagation)

## Executive Summary
This project demonstrates the decommissioning of legacy SAP Process Orchestration (PI/PO 7.5) dual-stack proxy interfaces and the end-to-end migration to **SAP Integration Suite (Cloud Integration)** within an **Oil & Gas Enterprise** landscape. 

The integration architecture implements SAP's **Clean Core** strategy: eliminating custom ABAP Z-tables, deprecating legacy synchronous RFC/SOAP endpoints, and exposing native **OData V4** RESTful services consumed via secure hybrid connectivity using **SAP Cloud Connector** and **Principal Propagation (X.509)**.

---

## Architecture Overview

### High-Level Topology
```text
[Field SCADA / Metering] 
       │
       │ SOAP 1.x (HTTPS / MTOM)
       ▼
[SAP Integration Suite (BTP)]
  ├── Channel: Inbound SOAP 1.x (/erp/energy/sync)
  ├── Transformation Layer:
  │     ├── XSLT Mapping (Tag Normalization & Legacy Deprecation)
  │     └── Message Mapping (Payload Transformation & Type Casting)
  └── Channel: Outbound OData V4 (Proxy: On-Premise)
       │
       │ Reverse Invoke Tunnel (TLS 1.3)
       ▼
[SAP Cloud Connector]
  ├── Subaccount Binding & Resource Whitelisting
  └── Short-Lived X.509 Certificate Generation (Principal Propagation)
       │
       │ HTTPS / OData V4 API
       ▼
[SAP S/4HANA Enterprise Core (On-Premise)]
  └── API: /sap/opu/odata4/sap/api_goodsmovement/srvd_a2x/sap/goodsmovement/0001
      (Clean Core Standard Goods Movement Posting)
```

---

## Technical Specifications

| Component | Technical Implementation | Architectural Justification |
| :--- | :--- | :--- |
| **Inbound Interface** | SOAP 1.x (`/erp/energy/sync`) | Backward compatibility for field SCADA/DCS systems without refactoring perimeter sensors |
| **Pipeline Transform 1** | XSLT 1.0 (`energy_transform.xslt`) | High-performance namespace stripping and legacy field normalization (`LegacyPlantID` -> `PlantID`) |
| **Pipeline Transform 2** | Graphical Message Mapping (`MM_SOAP_to_S4_OData`) | Structural mapping to S/4HANA standard goods movement schema (`GoodsMovement`) |
| **Outbound Interface** | OData V4 Adapter (`Create / POST`) | Clean Core native transactional consumption; replaces legacy BAPI/RFC function modules |
| **Hybrid Transport** | SAP Cloud Connector (Reverse Invoke) | Zero inbound ports opened on corporate on-premise firewall; TLS 1.3 encrypted tunnel |
| **Authentication** | Principal Propagation via X.509 | Cryptographic user identity propagation from BTP IdP directly to S/4HANA audit log |

---

## Repository Structure

```text
├── artifacts/
│   ├── SOAP_to_S4_OData.zip           # Exported SAP Integration Suite iFlow package
│   └── src/
│       ├── energy_transform.xslt       # XSLT 1.0 tag conversion & normalization script
│       ├── Source_Energy_SOAP.xsd     # Inbound metering XML schema definition
│       └── Target_S4_OData.xsd        # Outbound S/4HANA GoodsMovement OData schema
├── docs/
│   ├── architecture-diagram.png       # End-to-end interface architecture diagram
│   └── cloud-connector-config.md      # SCC Virtual-to-Internal mapping specification
└── README.md
```

---

## Security & Identity Propagation

In mission-critical Oil & Gas operations, shared technical users (`RFC_USER`, `BATCH_USER`) violate SOX compliance and audit traceability requirements. This architecture implements **Principal Propagation**:

1. **Sender Authentication:** Upstream metering systems authenticate against SAP BTP via OAuth 2.0 / Client Credentials or User Roles.
2. **Context Preservation:** CPI runtime preserves user identity within the exchange security header.
3. **Cloud Connector Token Exchange:** SCC intercepts the request, verifies the BTP identity token against the Corporate Identity Provider (SAP IAS / Active Directory).
4. **X.509 Issue:** A short-lived (30-second validity) X.509 client certificate is dynamically generated matching the SAP ERP user ID.
5. **S/4HANA Execution:** Transactional posting in S/4HANA (`MIGO` / Goods Movement) executes directly under the specific operator's identity (`SY-UNAME`).

---

## Enterprise Clean Core Compliance

* **Decoupled Architecture:** Business logic resides entirely within standard S/4HANA core APIs; orchestration and transformation remain decoupled on SAP BTP.
* **Zero Modification:** Eliminates custom Z-table persistence and custom BAPI wrappers in ERP.
* **Upgrade Safety:** Changes to upstream telemetry formats require updates exclusively in CPI XSLT layers without impacting ERP transport management or core system upgrades.

---

## Author
**Željko Popov**  
*SAP Integration Architect & Lead*  
Certified Boomi Integration Architect | SAP Integration Suite Specialist
