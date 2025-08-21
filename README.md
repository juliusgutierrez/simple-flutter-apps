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
