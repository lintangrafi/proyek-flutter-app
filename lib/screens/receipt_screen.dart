import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/purchase_order.dart';

class ReceiptScreen extends StatelessWidget {
  final PurchaseOrder po;
  const ReceiptScreen({super.key, required this.po});

  String formatRupiah(num number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }

  Future<pw.Document> _buildPdfReceipt() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'PURCHASE ORDER RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text('PO Number: ${po.poNumber}'),
              pw.Text('Tanggal: ${po.date}'),
              pw.Text('Vendor: ${po.vendorName}'),
              pw.Text('Status: ${po.status}'),
              pw.SizedBox(height: 12),
              pw.Text('Items:'),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Produk',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Unit',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Subtotal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...po.items.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('${item.name}'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('${item.quantity}'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('${item.unit}'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            formatRupiah(item.price * item.quantity),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: ' + formatRupiah(po.total),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.Text(
                'Terima kasih, silakan cetak/arsip receipt ini.',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );
    return doc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF4FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2266B4),
        title: const Text('Struk Purchase Order'),
        actions: [
          IconButton(
            tooltip: 'Cetak',
            icon: Icon(Icons.print),
            onPressed: () async {
              final doc = await _buildPdfReceipt();
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => doc.save(),
              );
            },
          ),
          IconButton(
            tooltip: 'Share/Export',
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final doc = await _buildPdfReceipt();
              await Printing.sharePdf(
                bytes: await doc.save(),
                filename: 'purchase_order_${po.poNumber}.pdf',
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          color: Colors.white,
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Color(0xFF2266B4),
                        size: 36,
                      ),
                      Text(
                        'Purchase Order Receipt',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF2266B4),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'PO Number: ${po.poNumber}',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  'Tanggal: ${po.date}',
                  style: TextStyle(color: Color(0xFF808080)),
                ),
                Text('Vendor: ${po.vendorName}'),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: BoxDecoration(
                    color:
                        po.status == 'Menunggu Persetujuan'
                            ? Colors.orange[100]
                            : po.status == "Disetujui"
                            ? Colors.green[100]
                            : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    po.status,
                    style: TextStyle(
                      color:
                          po.status == "Menunggu Persetujuan"
                              ? Colors.orange
                              : po.status == "Disetujui"
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
                Divider(height: 28),
                Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                ...po.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.name} (${item.quantity} ${item.unit})',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          formatRupiah(item.price * item.quantity),
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 34),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatRupiah(po.total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF2266B4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
