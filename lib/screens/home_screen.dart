import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/purchase_order.dart';
import '../providers/purchase_order_provider.dart';
import '../providers/goods_receipt_provider.dart';
import '../providers/invoice_provider.dart';
import 'account_detail_screen.dart';
import 'create_po_screen.dart';
import 'purchase_order_list_screen.dart';
import 'po_detail_screen.dart';

String shortDate(String d) => d.length > 10 ? d.substring(0, 10) : d;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      Provider.of<PurchaseOrderProvider>(
        context,
        listen: false,
      ).loadPurchaseOrders();
      Provider.of<GoodsReceiptProvider>(
        context,
        listen: false,
      ).loadGoodsReceipts();
      Provider.of<InvoiceProvider>(
        context,
        listen: false,
      ).loadInvoices();
      _didLoad = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final poProvider = Provider.of<PurchaseOrderProvider>(context);
    final grProvider = Provider.of<GoodsReceiptProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final allOrders = poProvider.orders;
    final allReceipts = grProvider.goodsReceipts;
    final allInvoices = invoiceProvider.invoices;

    // PO stats
    final int draftCount =
        allOrders
            .where(
              (o) =>
                  o.status.toLowerCase() == "draft" ||
                  o.status.toLowerCase() == "menunggu persetujuan" ||
                  o.status.toLowerCase() == "pending",
            )
            .length;
    final int approvedCount =
        allOrders
            .where(
              (o) =>
                  o.status.toLowerCase() == "approved" ||
                  o.status.toLowerCase() == "disetujui",
            )
            .length;
    // GR stats
    final int grPending =
        allReceipts.where((g) => g.status.toLowerCase() == "pending").length;
    final int grCompleted =
        allReceipts
            .where(
              (g) =>
                  g.status.toLowerCase() == "completed" ||
                  g.status.toLowerCase() == "selesai",
            )
            .length;
    // Invoice stats
    final int invoiceDraft = allInvoices.where((inv) => inv.status.toLowerCase() == 'draft').length;
    final int invoicePaid = allInvoices.where((inv) => inv.status.toLowerCase() == 'paid').length;

    final Color primaryColor = const Color(0xFF1A4A8B);
    final Color accentColorGreen = Colors.green.shade700;
    final Color accentColorOrange = Colors.orange.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 4, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Selamat datang kembali!",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      // radius: 24,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AccountDetailScreen(),
                          ),
                        );
                      },
                      color: Colors.white,
                      icon: Icon(
                        Icons.person_outline_rounded,
                        color: primaryColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // New Dashboard Buttons
              Column(
                children: [
                  _DashboardMenuButton(
                    color: primaryColor,
                    icon: Icons.library_books_outlined,
                    title: 'Purchase Order',
                    stats: [
                      _MenuStat(
                        label: 'Draft',
                        value: draftCount,
                        color: accentColorOrange,
                      ),
                      _MenuStat(
                        label: 'Approved',
                        value: approvedCount,
                        color: accentColorGreen,
                      ),
                    ],
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PurchaseOrderListScreen(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 18),
                  _DashboardMenuButton(
                    color: Colors.indigo,
                    icon: Icons.inventory_2_outlined,
                    title: 'Goods Receipt',
                    stats: [
                      _MenuStat(
                        label: 'Pending',
                        value: grPending,
                        color: accentColorOrange,
                      ),
                      _MenuStat(
                        label: 'Completed',
                        value: grCompleted,
                        color: accentColorGreen,
                      ),
                    ],
                    onTap: () => Navigator.pushNamed(context, '/receipt-list'),
                  ),
                  const SizedBox(height: 18),
                  _DashboardMenuButton(
                    color: Colors.teal,
                    icon: Icons.receipt_long,
                    title: 'Invoice',
                    stats: [
                      _MenuStat(
                        label: 'Draft',
                        value: invoiceDraft,
                        color: Colors.orange.shade700,
                      ),
                      _MenuStat(
                        label: 'Paid',
                        value: invoicePaid,
                        color: accentColorGreen,
                      ),
                    ],
                    onTap: () => Navigator.pushNamed(context, '/invoice-list'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // ...You may add recent PO/GR/Invoice list here if needed...
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardMenuButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final List<_MenuStat> stats;
  final VoidCallback onTap;
  const _DashboardMenuButton({
    required this.color,
    required this.icon,
    required this.title,
    required this.stats,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(80), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(18),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 18,
                    runSpacing: 4,
                    children:
                        stats
                            .map(
                              (s) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 10, color: s.color),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${s.label}: ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${s.value}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: s.color,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 32,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuStat {
  final String label;
  final int value;
  final Color color;
  _MenuStat({required this.label, required this.value, required this.color});
}
