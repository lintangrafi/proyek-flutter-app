# Testing

To ensure the reliability and quality of the application, thorough testing is conducted using Flutter's testing framework.

## Running Tests

1. **Prerequisites**:
   - Ensure Flutter and Dart are installed on your system.
   - Navigate to the project's root directory.

2. **Command to Run Tests**:
   ```bash
   flutter test
   ```

## Test Examples

### Widget Test Example

```dart
testWidgets('POItemCard displays correct data', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: POItemCard(
        title: 'Test Item',
        quantity: 2,
        unitPrice: 500.00,
      ),
    ),
  );

  expect(find.text('Test Item'), findsOneWidget);
  expect(find.text('Quantity: 2'), findsOneWidget);
  expect(find.text('Unit Price: \$500.00'), findsOneWidget);
  expect(find.text('Total: \$1,000.00'), findsOneWidget);
});
```

### Provider Test Example

```dart
void main() {
  group('PurchaseOrderProvider Tests', () {
    PurchaseOrderProvider provider = PurchaseOrderProvider();

    test('Create new purchase order', () {
      PurchaseOrder po = provider.createPurchaseOrder(
        vendorId: '123',
        warehouseId: '456',
        date: DateTime.now(),
        status: 'Pending',
        items: [
          PurchaseOrderItem(
            productId: '789',
            quantity: 10,
            unitPrice: 100.00,
          ),
        ],
      );

      expect(po.id, isNotEmpty);
      expect(po.vendorId, equals('123'));
      expect(po.items.length, equals(1));
    });
  });
}
```

## Best Practices

- **Write Unit Tests**: Ensure each component has corresponding unit tests.
- **Maintain Test Coverage**: Aim for high test coverage to catch regressions early.
- **Keep Tests Updated**: Update tests whenever new features are added or existing ones are modified.

By following these guidelines, we can maintain a robust and reliable application.