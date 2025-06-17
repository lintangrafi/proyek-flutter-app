import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/purchase_order.dart';
import '../providers/purchase_order_provider.dart';
import 'create_po_screen.dart';
import 'purchase_order_list_screen.dart';
import 'po_detail_screen.dart';

String shortDate(String d) => d.length > 10 ? d.substring(0, 10) : d;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25), // 0.1*255 ~ 25
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final int count;
  final String title;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.count,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(25), // 0.1*255 ~ 25
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(76), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: color.withAlpha(229)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _POListCard extends StatelessWidget {
  final PurchaseOrder po;

  const _POListCard({required this.po});

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
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            Icons.receipt_long_outlined,
            color: Color(0xFF1A4A8B),
            size: 26,
          ),
        ),
        title: Text(
          po.poNumber,
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
              po.vendorName,
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Tanggal: ${shortDate(po.date)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Tooltip(
          message: po.status,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(31),
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseOrderProvider>(
        context,
        listen: false,
      ).loadPurchaseOrders();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poProvider = Provider.of<PurchaseOrderProvider>(context);
    final allOrders = poProvider.orders;

    final int totalPO = allOrders.length;
    final int pendingCount =
        allOrders.where((o) => o.status == "Menunggu Persetujuan").length;
    final int approvedCount =
        allOrders.where((o) => o.status == "Disetujui").length;
    final int rejectedCount =
        allOrders.where((o) => o.status == "Ditolak").length;

    final pendingOrders =
        allOrders.where((o) => o.status == "Menunggu Persetujuan").toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final approvedOrders =
        allOrders.where((o) => o.status == "Disetujui").toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final rejectedOrders =
        allOrders.where((o) => o.status == "Ditolak").toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final Color primaryColor = const Color(0xFF1A4A8B);
    final Color accentColorOrange = Colors.orange.shade700;
    final Color accentColorGreen = Colors.green.shade700;
    final Color accentColorRed = Colors.red.shade700;

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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: primaryColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    _OverviewCard(
                      count: totalPO,
                      title: "Total PO",
                      icon: Icons.library_books_outlined,
                      color: primaryColor,
                    ),
                    SizedBox(width: 10),
                    _OverviewCard(
                      count: pendingCount,
                      title: "Menunggu",
                      icon: Icons.hourglass_top_rounded,
                      color: accentColorOrange,
                    ),
                    SizedBox(width: 10),
                    _OverviewCard(
                      count: approvedCount,
                      title: "Disetujui",
                      icon: Icons.verified_outlined,
                      color: accentColorGreen,
                    ),
                    SizedBox(width: 10),
                    _OverviewCard(
                      count: rejectedCount,
                      title: "Ditolak",
                      icon: Icons.cancel_outlined,
                      color: accentColorRed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 1.5,
                color: Colors.white,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: "Buat PO",
                        color: primaryColor,
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreatePOScreen(),
                              ),
                            ),
                      ),
                      _QuickActionButton(
                        icon: Icons.inventory_2_outlined,
                        label: "Goods Receipt",
                        color: Colors.indigo,
                        onTap: () => Navigator.pushNamed(context, '/create-gr'),
                      ),
                      _QuickActionButton(
                        icon: Icons.assessment_outlined,
                        label: "Laporan",
                        color: accentColorOrange,
                        onTap:
                            () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Fitur laporan segera hadir!"),
                                backgroundColor: accentColorOrange,
                                behavior: SnackBarBehavior.floating,
                              ),
                            ),
                      ),
                      _QuickActionButton(
                        icon: Icons.settings_outlined,
                        label: "Pengaturan",
                        color: accentColorGreen,
                        onTap:
                            () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Fitur pengaturan segera hadir!"),
                                backgroundColor: accentColorGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Purchase Order Terbaru",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: primaryColor,
                    ),
                  ),
                  if (allOrders.isNotEmpty)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        foregroundColor: primaryColor,
                      ),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PurchaseOrderListScreen(),
                            ),
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Lihat semua",
                            style: TextStyle(fontSize: 13),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 20),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        spreadRadius: 0.5,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: primaryColor,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  unselectedLabelColor: Colors.grey[600],
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.5,
                  ),
                  splashBorderRadius: BorderRadius.circular(10),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                  tabs: [
                    _buildTab('Menunggu', Icons.hourglass_empty_rounded),
                    _buildTab('Disetujui', Icons.check_circle_outline_rounded),
                    _buildTab('Ditolak', Icons.cancel_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPOList(
                      pendingOrders,
                      'Belum ada PO menunggu persetujuan.',
                    ),
                    _buildPOList(
                      approvedOrders,
                      'Belum ada PO yang disetujui.',
                    ),
                    _buildPOList(rejectedOrders, 'Tidak ada PO yang ditolak.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, IconData icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, softWrap: false, overflow: TextOverflow.fade),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOList(List<PurchaseOrder> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(178),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 40),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: orders.map((po) => _POListCard(po: po)).toList(),
      );
    }
  }
}
