# Architecture Proposal: Fuelytics

## Contexts

### Verification

- **Type:** context
- **Description:** Driver-facing verification flow via PWA - SMS notifications, camera capture, photo upload, offline support
- **Stories:** 373, 374, 375, 376, 377, 378, 383

#### Children

- Request (schema): A pending verification request triggered by fuel transaction
- Photo (schema): Captured photo with EXIF metadata and GPS coordinates
- SmsNotifier (module): Send SMS with PWA deep links to drivers
- PhotoCapture (module): Handle camera, EXIF extraction, offline queue

### PhotoAnalysis

- **Type:** context
- **Description:** Automated photo processing - OCR, QR recognition, GPS/timestamp validation
- **Stories:** 379, 380, 381, 382

#### Children

- Result (schema): Analysis results with extracted data and confidence scores
- OcrProcessor (module): Extract odometer readings via OCR
- QrScanner (module): Recognize vehicle ID stickers and QR codes
- LocationValidator (module): Correlate photo GPS with station location
- TimestampValidator (module): Validate photo time against transaction time

### FraudDetection

- **Type:** context
- **Description:** Manager-facing fraud analysis - alerts, flagged transactions, violation tracking, LLM analysis
- **Stories:** 385, 386, 387, 389, 390

#### Children

- Alert (schema): A flagged transaction requiring manager review
- Violation (schema): Confirmed violation linked to driver/card
- AlertEngine (module): Generate real-time alerts from analysis results
- RiskScorer (module): LLM-based anomaly detection and scoring
- Dashboard (module): Real-time pending verification and alert views

### Cards

- **Type:** context
- **Description:** Fuel card management - lock/unlock based on violations
- **Stories:** 384, 388

#### Children

- Card (schema): Fuel card with status and assignment
- LockManager (module): Lock cards on consecutive violations, unlock on review

### Reporting

- **Type:** context
- **Description:** Manager reporting - summaries and audit exports
- **Stories:** 391, 392

#### Children

- WeeklySummary (module): Generate weekly verification and fraud summaries
- AuditExport (module): Export audit trails for compliance

## Surface Components

_No surface components defined_

## Dependencies

- Fuelytics.Verification -> Fuelytics.PhotoAnalysis
- Fuelytics.FraudDetection -> Fuelytics.PhotoAnalysis
- Fuelytics.FraudDetection -> Fuelytics.Cards
- Fuelytics.Reporting -> Fuelytics.FraudDetection
- Fuelytics.Reporting -> Fuelytics.Verification