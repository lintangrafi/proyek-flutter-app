# Project Documentation: Purchase Order Application

## Overview
This project is a Flutter-based Purchase Order (PO) application with a Laravel backend. It facilitates the workflow of creating purchase orders, goods receipts, and invoices, while integrating warehouse management, price validation, status tracking, and role-based access control.

## Features
1. **Purchase Order Workflow**:
   - Create PO with vendor, warehouse, item details, and automatic price calculation.
   - Validate PO data including mandatory fields and price consistency.
   - Approve PO based on user roles (e.g., Manager).

2. **Goods Receipt Workflow**:
   - Create GR with received quantity and item conditions.
   - Validate GR data and update backend.

3. **Invoice Workflow**:
   - Generate invoices based on completed GRs.

4. **Warehouse Integration**:
   - Dropdown selection for warehouse in PO form.
   - Consistent warehouse data between frontend and backend.

5. **Role-Based Access Control**:
   - User roles (e.g., Manager, Staff) determine access to features like PO approval.

6. **Data Validation**:
   - Ensure consistency of product prices, warehouse IDs, and statuses.

7. **UI Enhancements**:
   - Format prices to "Rp. 1.000" for display.
   - Consistent status mapping across screens.

8. **Debugging Utilities**:
   - Logger utility for debugging API responses and data parsing.

## Pending Tasks
- End-to-end validation of PO → Approval → GR → Invoice workflows.
- UI and validation improvements for edge cases.
- Backend validation for warehouse and product data.
- Ensure API responses are consistent.
- Optional features: multi-level approval, notifications, activity logs.

## Code Structure
- **lib/models**: Contains data models for PO, GR, products, warehouses, users, etc.
- **lib/providers**: State management for PO, GR, products, vendors, warehouses, and authentication.
- **lib/screens**: UI screens for creating and listing POs, GRs, and invoices.
- **lib/services**: API service for backend communication.
- **lib/utils**: Utility functions like logger.

## Installation
1. Clone the repository.
2. Install dependencies using `flutter pub get`.
3. Configure backend API URL in `lib/services/api_service.dart`.
4. Run the application using `flutter run`.

## Backend Integration
- Ensure Laravel backend is running and API endpoints are accessible.
- Update API base URL in `lib/services/api_service.dart`.

## Contribution Guidelines
1. Follow coding standards and naming conventions.
2. Write unit tests for new features.
3. Document code changes in the `docs/CHANGELOG.md` file.

## Contact
For any issues or contributions, contact the project maintainer at [email@example.com].
