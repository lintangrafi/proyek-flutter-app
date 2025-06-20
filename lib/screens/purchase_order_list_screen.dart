import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/purchase_order.dart';
import '../providers/purchase_order_provider.dart';
import 'po_detail_screen.dart';
import 'create_po_screen.dart';

String shortDate(String d) => d.length > 10 ? d.substring(0, 10) : d;

class PurchaseOrderListScreen extends StatelessWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final poProvider = Provider.of<PurchaseOrderProvider>(context);
    final List<PurchaseOrder> draftOrders =
        poProvider.orders
            .where(
              (po) =>
                  po.status.toLowerCase() == 'draft' ||
                  po.status.toLowerCase().contains('menunggu') ||
                  po.status.toLowerCase().contains('pending'),
            )
            .toList();
    final List<PurchaseOrder> approvedOrders =
        poProvider.orders
            .where(
              (po) =>
                  po.status.toLowerCase() == 'approved' ||
                  po.status.toLowerCase().contains('disetujui'),
            )
            .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF4FB),
        appBar: AppBar(
          title: const Text('Daftar Purchase Order'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorWeight: 3,
            tabs: [Tab(text: 'Draft'), Tab(text: 'Approved')],
          ),
          backgroundColor: Color(0xFF1A4A8B),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Draft',
                      value: draftOrders.length,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Approved',
                      value: approvedOrders.length,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  // Draft Tab
                  draftOrders.isEmpty
                      ? Center(child: Text('Tidak ada PO Draft'))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                        itemCount: draftOrders.length,
                        itemBuilder: (context, index) {
                          final po = draftOrders[index];
                          return _POListCardItem(po: po);
                        },
                      ),
                  // Approved Tab
                  approvedOrders.isEmpty
                      ? Center(child: Text('Tidak ada PO Disetujui'))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                        itemCount: approvedOrders.length,
                        itemBuilder: (context, index) {
                          final po = approvedOrders[index];
                          return _POListCardItem(po: po);
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePOScreen()),
              ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Buat PO', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1A4A8B),
        ),
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

// Tambahkan widget statistik card
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
