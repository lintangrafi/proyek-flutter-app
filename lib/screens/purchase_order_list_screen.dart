import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/purchase_order.dart';
import '../providers/purchase_order_provider.dart';
import 'po_detail_screen.dart';

String shortDate(String d) => d.length > 10 ? d.substring(0, 10) : d;

class PurchaseOrderListScreen extends StatelessWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final poProvider = Provider.of<PurchaseOrderProvider>(context);
    final List<PurchaseOrder> allOrders = poProvider.orders;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF4FB),
      appBar: AppBar(title: const Text('Semua Purchase Order')),
      body:
          allOrders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt_rounded,
                      color: Colors.grey[400],
                      size: 50,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada Purchase Order',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 10.0,
                ),
                itemCount: allOrders.length,
                itemBuilder: (context, index) {
                  final po = allOrders[index];
                  return _POListCardItem(po: po);
                },
              ),
    );
  }
}

class _POListCardItem extends StatelessWidget {
  final PurchaseOrder po;

  const _POListCardItem({required this.po});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;

    switch (po.status) {
      case 'Menunggu Persetujuan':
        badgeColor = Colors.orange.shade700;
        badgeIcon = Icons.hourglass_empty_rounded;
        break;
      case 'Disetujui':
        badgeColor = Colors.green.shade700;
        badgeIcon = Icons.check_circle_outline_rounded;
        break;
      case 'Ditolak':
        badgeColor = Colors.red.shade700;
        badgeIcon = Icons.cancel_outlined;
        break;
      default:
        badgeColor = Colors.grey.shade500;
        badgeIcon = Icons.help_outline_rounded;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF1A4A8B).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF1A4A8B),
            size: 26,
          ),
        ),
        title: Text(
          po.poNumber,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1A4A8B),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text(
              po.vendorName,
              style: TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              'Tanggal: ${shortDate(po.date)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Tooltip(
          message: po.status,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(badgeIcon, color: badgeColor, size: 18),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PODetailScreen(poId: po.id.toString()),
            ),
          );
        },
      ),
    );
  }
}
