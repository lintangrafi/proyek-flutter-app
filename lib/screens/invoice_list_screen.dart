import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import './create_invoice_screen.dart';
import './invoice_detail_screen.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final invoices = invoiceProvider.invoices;
    final draftInvoices =
        invoices.where((inv) => inv.status.toLowerCase() == 'draft').toList();
    final paidInvoices =
        invoices.where((inv) => inv.status.toLowerCase() == 'paid').toList();

    // Tambahkan auto load jika belum ada data
    if (invoices.isEmpty) {
      Future.microtask(() => invoiceProvider.loadInvoices());
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF4FB),
        appBar: AppBar(
          title: const Text('Daftar Invoice'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorWeight: 3,
            tabs: [Tab(text: 'Draft'), Tab(text: 'Paid')],
          ),
          backgroundColor: Colors.teal,
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
                      value: draftInvoices.length,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Paid',
                      value: paidInvoices.length,
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
                  draftInvoices.isEmpty
                      ? const Center(child: Text('Tidak ada Invoice Draft'))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                        itemCount: draftInvoices.length,
                        itemBuilder: (context, index) {
                          final inv = draftInvoices[index];
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
                                  color: Colors.indigo.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  color: Colors.indigo,
                                  size: 26,
                                ),
                              ),
                              title: Text(
                                inv.invoiceNumber.isNotEmpty
                                    ? inv.invoiceNumber
                                    : 'Invoice#${inv.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.indigo,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tanggal: ${inv.date}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${inv.status}',
                                    style: const TextStyle(
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
                                          (_) => InvoiceDetailScreen(
                                            invoiceId: inv.id,
                                          ),
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                  // Paid Tab
                  paidInvoices.isEmpty
                      ? const Center(child: Text('Tidak ada Invoice Paid'))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                        itemCount: paidInvoices.length,
                        itemBuilder: (context, index) {
                          final inv = paidInvoices[index];
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
                                  color: Colors.indigo.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  color: Colors.indigo,
                                  size: 26,
                                ),
                              ),
                              title: Text(
                                inv.invoiceNumber.isNotEmpty
                                    ? inv.invoiceNumber
                                    : 'Invoice#${inv.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.indigo,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tanggal: ${inv.date}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${inv.status}',
                                    style: const TextStyle(
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
                                          (_) => InvoiceDetailScreen(
                                            invoiceId: inv.id,
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
                MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
              ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Buat Invoice',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
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
