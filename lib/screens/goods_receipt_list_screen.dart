import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goods_receipt_provider.dart';
import '../models/goods_receipt.dart';
import 'create_gr_screen.dart';
import 'goods_receipt_detail_screen.dart';

class GoodsReceiptListScreen extends StatelessWidget {
  const GoodsReceiptListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grProvider = Provider.of<GoodsReceiptProvider>(context);
    final List<GoodsReceipt> pendingReceipts =
        grProvider.goodsReceipts
            .where((gr) => gr.status.toLowerCase() == 'pending')
            .toList();
    final List<GoodsReceipt> completedReceipts =
        grProvider.goodsReceipts
            .where(
              (gr) =>
                  gr.status.toLowerCase() == 'completed' ||
                  gr.status.toLowerCase() == 'selesai',
            )
            .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF4FB),
        appBar: AppBar(
          title: const Text('Daftar Goods Receipt'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorWeight: 3,
            tabs: [Tab(text: 'Pending'), Tab(text: 'Completed')],
          ),
          backgroundColor: Colors.indigo,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Pending',
                      value: pendingReceipts.length,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Completed',
                      value: completedReceipts.length,
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
                  // Pending Tab
                  pendingReceipts.isEmpty
                      ? Center(child: Text('Tidak ada GR Pending'))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                        itemCount: pendingReceipts.length,
                        itemBuilder: (context, index) {
                          final gr = pendingReceipts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: Colors.white,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A4A8B).withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Color(0xFF1A4A8B),
                                  size: 26,
                                ),
                              ),
                              title: Text(
                                gr.grNumber.isNotEmpty
                                    ? gr.grNumber
                                    : 'GR#${gr.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1A4A8B),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tanggal: ${gr.tanggal}',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${gr.status}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => GoodsReceiptDetailScreen(
                                            grId: gr.id,
                                          ),
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                  // Completed Tab
                  completedReceipts.isEmpty
                      ? Center(child: Text('Tidak ada GR Completed'))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                        itemCount: completedReceipts.length,
                        itemBuilder: (context, index) {
                          final gr = completedReceipts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: Colors.white,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A4A8B).withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Color(0xFF1A4A8B),
                                  size: 26,
                                ),
                              ),
                              title: Text(
                                gr.grNumber.isNotEmpty
                                    ? gr.grNumber
                                    : 'GR#${gr.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1A4A8B),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tanggal: ${gr.tanggal}',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${gr.status}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => GoodsReceiptDetailScreen(
                                            grId: gr.id,
                                          ),
                                    ),
                                  ),
                            ),
                          );
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
                MaterialPageRoute(
                  builder: (_) => const CreateGoodsReceiptScreen(),
                ),
              ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Buat GR', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigo,
        ),
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
