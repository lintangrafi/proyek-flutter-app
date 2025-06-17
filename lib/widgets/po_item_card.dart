import 'package:flutter/material.dart';
import '../models/purchase_order.dart';

class POItemCard extends StatelessWidget {
  final PurchaseOrder po;
  final Function onTap;

  const POItemCard({super.key, required this.po, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PO #${po.poNumber}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  _buildStatusBadge(po.status),
                ],
              ),
              SizedBox(height: 8),
              Text('Vendor: ${po.vendorName}'),
              Text('Date: ${po.date}'),
              Text(
                'Total: Rp ${po.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ".")}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Menunggu Persetujuan':
        color = Colors.orange;
        break;
      case 'Disetujui':
        color = Colors.green;
        break;
      case 'Dikirim':
        color = Colors.blue;
        break;
      case 'Dibatalkan':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
