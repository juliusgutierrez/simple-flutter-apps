```plaintext
ps-create-workitem/
├── shared-kernel/                      # tiny, stable domain VOs only (no external DTOs)
│   └── domain/
│       └── valueobject/
│           ├── Money.java
│           └── PolicyNumber.java
│
├── platform/
│   ├── salesforce-client/              # reusable plumbing (auth/http/retry + SFDC request/response DTOs)
│   │   └── src/main/java/platform/salesforce/client/{...}
│   └── okta-client/                    # same idea for Okta
│       └── src/main/java/platform/okta/client/{...}
│
├── workitem-submission/                # shared capability (canonical contract for creating work items)
│   ├── application/
│   │   ├── usecase/
│   │   │   └── SubmitWorkItemUseCase.java     # inbound port exposed to callers (the 6 report modules)
│   │   ├── ports/
│   │   │   └── OutboundTargetPort.java        # outbound port (e.g., to Salesforce or other targets)
│   │   ├── services/
│   │   │   └── WorkItemSubmissionService.java # orchestrates dedupe/idempotency/routing/retries
│   │   └── dto/
│   │       └── SubmitWorkItemCommand.java     # canonical Published Language (v1, version when needed)
│   ├── domain/
│   │   ├── aggregate/                         # WorkItemSubmission ledger, idempotency keys, routing policy
│   │   ├── entity/
│   │   ├── valueobject/
│   │   │   ├── SubmissionKey.java
│   │   │   └── Route.java
│   │   ├── policy/
│   │   ├── event/
│   │   │   ├── WorkItemSubmitted.java
│   │   │   └── WorkItemDuplicateDetected.java
│   │   └── exception/
│   └── infrastructure/
│       ├── salesforce/
│       │   └── SalesforceTargetAdapter.java   # implements OutboundTargetPort; maps command → platform DTOs
│       └── persistence/
│           └── SubmissionLedgerRepositoryImpl.java
│
├── batch/                                # presentation/orchestration; Strategy to pick which ingestion to run
│   ├── presentation/
│   │   └── cli/
│   │       └── BatchMain.java            # reads args[0], prints help/--list
│   ├── application/
│   │   ├── orchestrator/
│   │   │   └── BatchOrchestrator.java    # runs selected use case, aggregates summaries
│   │   └── routing/
│   │       ├── UseCaseResolver.java      # Strategy registry: key → IngestionUseCase
│   │       └── RoutingConfig.java        # optional externalized mapping (e.g., YAML)
│   └── config/
│       └── BatchWiring.java
│
├── ingenium-report/                       # 1 of 6 – file-based (example)
│   ├── application/
│   │   ├── usecase/
│   │   │   └── IngestIngeniumReportUseCase.java   # Strategy interface implementation
│   │   ├── ports/
│   │   │   ├── FileScannerPort.java
│   │   │   ├── RowStreamPort.java
│   │   │   └── WorkItemSubmissionPort.java        # outbound port to workitem-submission (not Salesforce)
│   │   ├── services/
│   │   │   └── IngeniumReportService.java
│   │   └── dto/
│   │       └── WorkItemView.java                  # context-specific view to map → SubmitWorkItemCommand
│   ├── domain/
│   │   ├── aggregate/ Report.java
│   │   ├── entity/    ReportRow.java
│   │   ├── valueobject/ {ReportId, TransactionNumber, TransactionType, ReportFileName, ReportSchema}.java
│   │   ├── policy/    {BusinessRules, ReportRowValidator}.java
│   │   ├── event/     {RowParsed, RowRejected}.java
│   │   └── exception/
│   └── infrastructure/
│       ├── fs/           FsFileScanner.java           # implements FileScannerPort
│       ├── parsing/      FixedWidthRowStream.java     # implements RowStreamPort (offset/length rules)
│       └── submission/   WorkItemSubmissionAdapter.java
│                         # implements WorkItemSubmissionPort; maps WorkItemView → SubmitWorkItemCommand
│
├── bank-upload-report/                    # 2 of 6 – DB-based (example)
│   ├── application/
│   │   ├── usecase/   IngestBankUploadReportUseCase.java
│   │   ├── ports/     {DbCursorPort.java, WorkItemSubmissionPort.java}
│   │   ├── services/  BankUploadReportService.java
│   │   └── dto/       WorkItemView.java
│   ├── domain/        # bank-specific schema & validators
│   └── infrastructure/
│       ├── db/        JdbcCursorAdapter.java         # implements DbCursorPort
│       └── submission/WorkItemSubmissionAdapter.java # maps → SubmitWorkItemCommand
│
├── prism-report/                          # 3 of 6 – another feed (same pattern)
│   ├── application/ ...
│   ├── domain/ ...
│   └── infrastructure/
│       └── submission/ WorkItemSubmissionAdapter.java
│
├── report4/                               # 4 of 6 – placeholder, same layout
├── report5/                               # 5 of 6 – placeholder, same layout
└── report6/                               # 6 of 6 – placeholder, same layout
```

# UML Relationship Manifest

## Association
- **Meaning:** Long-lived structural link; objects hold references.  
- **Notation:** Solid line (no arrow) — bidirectional by default.  
- **Use when:** Both classes know each other (navigation both ways) or you deliberately model a mutual link.  
- **Code cues:** Fields on both sides.  
- **Lifecycle/ownership:** None implied.  
- **Multiplicity:** Yes (`1`, `0..1`, `0..*`, `1..*`).  
- **Example:** `Customer — Order` (both reference each other).  

---

## Directed Association
- **Meaning:** Structural link, but one-way navigation.  
- **Notation:** Solid line with open arrow toward the known class.  
- **Use when:** One class holds a field to the other; the other does not point back.  
- **Code cues:** Field on one side only (e.g., DI collaborator).  
- **Lifecycle/ownership:** None implied.  
- **Multiplicity:** Yes (often `1` on source side, `0..*` on target).  
- **Example:** `ProcessIngeniumReportService ──▷ ReportJobParser`.  

---

## Dependency
- **Meaning:** “Uses” relationship; temporary coupling (method sigs, locals).  
- **Notation:** Dashed line with open arrow.  
- **Use when:** Type appears in parameter/return type/local var, factory use, static calls.  
- **Code cues:** No stored field; appears only in method signatures/bodies.  
- **Lifecycle/ownership:** None; short-lived.  
- **Multiplicity:** You *can* show (e.g., `0..*` for `List<T>`), but uncommon.  
- **Example:** `ReportRepository - -▷ Report` (returns `List<Report>`).  

---

## Interface Realization
- **Meaning:** Class implements an interface.  
- **Notation:** Dashed line with hollow triangle pointing to the interface.  
- **Use when:** Concrete type fulfills a contract.  
- **Code cues:** `class X implements IY`.  
- **Lifecycle/ownership:** N/A.  
- **Multiplicity:** N/A.  
- **Example:** `ProcessIngeniumReportUseCase ----▷ ProcessIngeniumReportService` (service is an interface).  

---

## Aggregation
- **Meaning:** Whole–part (weak “has-a”); parts can exist independently.  
- **Notation:** Solid line with open diamond at the whole.  
- **Use when:** Container references parts it does not own (catalog, team ↔ players).  
- **Code cues:** Field(s) to parts; parts also used elsewhere / shared lifecycles.  
- **Lifecycle/ownership:** No lifecycle control; parts survive without whole.  
- **Multiplicity:** Yes (often whole `1`, parts `0..*`).  
- **Example:** `Team ◇── Player`.  

---

## Composition
- **Meaning:** Whole–part (strong “has-a”); parts’ lifecycle bound to whole.  
- **Notation:** Solid line with filled diamond at the whole.  
- **Use when:** Whole creates/owns/destroys its parts; parts make no sense alone.  
- **Code cues:** Private constructors/factories for parts, parts not shared, removed with whole.  
- **Lifecycle/ownership:** Strong ownership; parts die with whole.  
- **Multiplicity:** Yes (commonly `1 ↔ 0..*`).  
- **Example:** `Report ◆── ColumnCode` (columns live & die with the report).  


Application Layer

Responsibility

Orchestrate use cases (application workflows).

Coordinate aggregates, enforce transactional boundaries, handle idempotency, retries, and mapping (DTO↔VO).

Define what the app offers (inbound) and needs (outbound) via ports.

Inbound/Outbound Ports

Inbound (input) ports: interfaces declaring use cases (e.g., CreateProductUseCase, GetProductByIdUseCase). Implemented by application services.

Outbound (output) ports: interfaces the application requires (e.g., ProductRepositoryPort, InventoryGatewayPort). Implemented by infrastructure adapters.

Important Notes

Depends only on Domain and port interfaces; never on infra frameworks.

Contains application services that implement inbound ports and call outbound ports.

Contains no business rules—business logic lives in Domain (entities/policies).

Good place for transactions, unit-of-work, authorization checks, input validation, and use-case level logging/metrics.

Domain Layer

Responsibility

The core model: aggregates, entities, value objects, domain events, and policies/specifications (pure business rules).

Maintain invariants and ubiquitous language; code should “scream the domain.”

Inbound/Outbound Ports

None. The domain is port-free and framework-free. It exposes behavior through methods on aggregates/services and raises domain events.

Important Notes

No Spring/JPA/HTTP imports—pure Java.

Use Domain Services/Policies only for logic that doesn’t naturally fit an aggregate.

Emit Domain Events for side-effects to be handled by the application layer.

Keep constructors/factories validating invariants; avoid setters that break consistency.

Infrastructure Layer (Adapters)

Responsibility

Implement the technical details to satisfy outbound ports and expose entry points for inbound ports.

Provide adapters:

Input adapters (drive the app): REST controllers, schedulers, message listeners — they call inbound ports.

Output adapters (driven by the app): DB repositories, message producers, HTTP clients — they implement outbound ports.

Config: wiring, persistence mappings, HTTP clients, serialization.

Inbound/Outbound Ports

Implements outbound ports (e.g., JdbcProductRepository implements ProductRepositoryPort).

Consumes inbound ports (e.g., ProductController depends on CreateProductUseCase).

Important Notes

Adapters translate between tech models (DTOs, JPA entities, payloads) and domain models (VOs/aggregates).

Keep mappers/ORM details here; domain must not see them.

One adapter per concern (REST, DB, MQ) to keep boundaries clean and testable.
