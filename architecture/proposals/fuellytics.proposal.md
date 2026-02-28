# Architecture Proposal: Fuellytics

## Contexts

### Fuellytics.Accounts
- **Type:** context
- **Description:** User authentication, fleet managers, and driver management
- **Stories:** 373, 374, 375, 377

#### Children
- User (schema): Fleet manager or admin user
- Driver (schema): Driver assigned to vehicles and fuel cards

### Fuellytics.Vehicles
- **Type:** context
- **Description:** Vehicle tracking and odometer management
- **Stories:** 385, 380, 389

#### Children
- Vehicle (schema): Fleet vehicle with QR sticker

### Fuellytics.Transactions
- **Type:** context
- **Description:** Fuel purchase transactions
- **Stories:** 376, 378, 382, 384, 387

#### Children
- Transaction (schema): Fuel purchase transaction
- FuelCard (schema): Fuel card assigned to driver/vehicle

### Fuellytics.FraudDetection
- **Type:** context
- **Description:** Anomaly detection, fraud alerts, and card locking
- **Stories:** 381, 388, 390

#### Children
- Alert (schema): Fraud alert requiring review
- AnomalyDetector (module): Detects suspicious transaction patterns

## Surface Components

### FuellyticsWeb.DriverLive
- **Type:** live_view
- **Description:** Driver mobile interface
- **Stories:** 373, 374
## Dependencies

- FuellyticsWeb.DriverLive -> Fuellytics.Accounts
- Fuellytics.Transactions -> Fuellytics.Vehicles