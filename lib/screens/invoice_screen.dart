import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

import '../models/invoice_item.dart';
import '../services/printer_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, this.isBangla = true, this.onLanguageToggle});

  final bool isBangla;
  final VoidCallback? onLanguageToggle;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  static const green = Color(0xFF07866A);
  final productController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final PrinterService printerService = PrinterService();
  final List<InvoiceItem> items = [];

  ReceiptController? receiptController;
  String? selectedPrinterAddress;
  String? selectedPrinterName;
  bool isPrinting = false;
  double? printProgress;

  late bool isBangla;

  @override
  void initState() {
    super.initState();
    isBangla = widget.isBangla;
  }

  String text(String bn, String en) => isBangla ? bn : en;

  double get grandTotal => items.fold(0, (total, item) => total + item.total);

  void addItem() {
    final name = productController.text.trim();
    final quantity = double.tryParse(quantityController.text);
    final price = double.tryParse(priceController.text);
    if (name.isEmpty || quantity == null || price == null) {
      showMessage(text('পণ্যের নাম, পরিমাণ ও দাম লিখুন', 'Enter a product, quantity and price'));
      return;
    }
    setState(() {
      items.add(InvoiceItem(name: name, quantity: quantity, price: price));
    });
    productController.clear();
    quantityController.clear();
    priceController.clear();
  }

  Future<void> selectPrinter() async {
    final printer = await printerService.selectPrinter(context);
    if (printer == null || !mounted) return;
    setState(() {
      selectedPrinterAddress = printer.address;
      selectedPrinterName = printer.name ?? 'Rongta Printer';
    });
    showMessage('${text('প্রিন্টার নির্বাচন করা হয়েছে', 'Printer selected')}: $selectedPrinterName');
  }

  Future<void> printInvoice() async {
    if (items.isEmpty) {
      showMessage(text('আগে পণ্য যোগ করুন', 'Add an item first'));
      return;
    }

    if (selectedPrinterAddress == null) {
      await selectPrinter();
      if (selectedPrinterAddress == null) {
        showMessage(text('আগে Rongta প্রিন্টার নির্বাচন করুন', 'Select the Rongta printer first'));
        return;
      }
    }

    if (receiptController == null) {
      showMessage(text('ইনভয়েস প্রিভিউ প্রস্তুত হয়নি', 'Invoice preview is not ready yet'));
      return;
    }

    setState(() {
      isPrinting = true;
      printProgress = null;
    });

    final success = await printerService.printReceipt(
      controller: receiptController!,
      address: selectedPrinterAddress!,
      onProgress: (total, sent) {
        if (!mounted || total == 0) return;
        setState(() {
          printProgress = sent / total;
        });
      },
    );

    if (!mounted) return;
    setState(() {
      isPrinting = false;
      printProgress = null;
    });
    showMessage(success
        ? text('ইনভয়েস প্রিন্টারে পাঠানো হয়েছে', 'Invoice sent to printer')
        : text('প্রিন্ট হয়নি। Bluetooth ও প্রিন্টার চালু আছে কি না দেখুন', 'Print failed. Check Bluetooth and printer power'));
  }

  @override
  void dispose() {
    productController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F6),
        title: Text(text('ইনভয়েস তৈরি', 'Create Invoice'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () { setState(() => isBangla = !isBangla); widget.onLanguageToggle?.call(); }, child: Text(text('English', 'বাংলা'))),
          IconButton(
            tooltip: text('প্রিন্টার নির্বাচন', 'Select Printer'),
            onPressed: isPrinting ? null : selectPrinter,
            icon: const Icon(Icons.bluetooth_searching, color: green),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
        children: [
          Text(text('কাস্টমার *', 'Customer *'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 9),
          _card(child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
            leading: const CircleAvatar(backgroundColor: Color(0xFFE7F7F1), child: Icon(Icons.storefront_outlined, color: green)),
            title: Text(text('ওয়াক-ইন কাস্টমার', 'Walk-in Customer'), style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(text('নগদ বিক্রি · কাস্টমার বাছাই করতে চাপ দিন', 'Cash sale · tap to choose a customer')),
            trailing: const Icon(Icons.keyboard_arrow_down),
          )),
          const SizedBox(height: 18),
          _card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                TextField(
                  controller: productController,
                  decoration: InputDecoration(labelText: text('পণ্যের নাম', 'Product Name'), prefixIcon: const Icon(Icons.cake_outlined), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: quantityController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: text('পরিমাণ', 'Quantity'), border: const OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: text('দর (৳)', 'Rate (৳)'), border: const OutlineInputBorder()))),
                ]),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: addItem, icon: const Icon(Icons.add), label: Text(text('পণ্য যোগ করুন', 'Add Item')))),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          _card(
            color: const Color(0xFFEAF8F4),
            child: items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(children: [
                      const Icon(Icons.shopping_cart_outlined, size: 42, color: green),
                      const SizedBox(height: 12),
                      Text(text('কার্ট খালি', 'Cart is empty'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(text('পণ্য যোগ করে বিক্রি শুরু করুন', 'Add products to start a sale'), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
                    ]),
                  )
                : Column(children: [
                    for (final item in items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${text('পরিমাণ', 'Qty')}: ${formatMoney(item.quantity)} × ৳${formatMoney(item.price)}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('৳${formatMoney(item.total)}', style: const TextStyle(fontWeight: FontWeight.bold, color: green)),
                          IconButton(onPressed: () => setState(() => items.remove(item)), icon: const Icon(Icons.close, size: 19)),
                        ]),
                      ),
                  ]),
          ),
          const SizedBox(height: 14),
          _card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _totalRow(text('সাবটোটাল', 'Subtotal'), grandTotal.toStringAsFixed(2)),
              const SizedBox(height: 14),
              _totalRow(text('ইনভয়েস ছাড়', 'Invoice Discount'), '৳0'),
              const SizedBox(height: 14),
              _totalRow(text('ভ্যাট (০%)', 'VAT (0%)'), '৳0.00'),
              const Divider(height: 24),
              _totalRow(text('সর্বমোট', 'Grand Total'), '৳${grandTotal.toStringAsFixed(2)}', bold: true),
            ]),
          )),
          const SizedBox(height: 14),
          const SizedBox(height: 18),
          Text(text('প্রিন্ট প্রিভিউ', 'Print Preview'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 8),
          if (items.isNotEmpty)
            SizedBox(
              height: 230 + items.length * 28,
              child: Receipt(
                backgroundColor: Colors.white,
                defaultTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
                onInitialized: (controller) => receiptController = controller,
                builder: (context) => _InvoiceReceipt(items: items, grandTotal: grandTotal, isBangla: isBangla),
              ),
            ),
          _card(child: Column(children: [
            ListTile(
              leading: const Icon(Icons.bluetooth, color: green),
              title: Text(selectedPrinterName ?? text('প্রিন্টার নির্বাচন করা হয়নি', 'No printer selected')),
              trailing: TextButton(onPressed: isPrinting ? null : selectPrinter, child: Text(text('নির্বাচন', 'Select'))),
            ),
            if (printProgress != null) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: LinearProgressIndicator(value: printProgress)),
          ])),
          const SizedBox(height: 16),
          SizedBox(
            height: 58,
            child: FilledButton.icon(
              onPressed: isPrinting ? null : printInvoice,
              icon: isPrinting ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.print_outlined),
              label: Text(isPrinting ? text('প্রিন্ট হচ্ছে...', 'Printing...') : text('ইনভয়েস প্রিন্ট', 'Print Invoice'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String formatMoney(double value) => value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);

  Widget _card({required Widget child, Color color = Colors.white}) => Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
        child: child,
      );

  Widget _totalRow(String title, String amount, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: bold ? 18 : 16, color: bold ? Colors.black : Colors.grey.shade700, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(amount, style: TextStyle(fontSize: bold ? 20 : 16, color: bold ? green : Colors.black, fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ],
      );

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InvoiceReceipt extends StatelessWidget {
  const _InvoiceReceipt({required this.items, required this.grandTotal, required this.isBangla});

  final List<InvoiceItem> items;
  final double grandTotal;
  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    final invoiceNo = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isBangla ? 'দেশপ্রিয় মিষ্টান্ন ভাণ্ডার' : 'Deshpriyo Sweets', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(isBangla ? 'ইনভয়েস' : 'INVOICE', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${isBangla ? 'ইনভয়েস' : 'Invoice'}: #$invoiceNo', style: const TextStyle(fontSize: 17)),
          Text('${isBangla ? 'তারিখ' : 'Date'}: ${_formatDateTime(DateTime.now())}', style: const TextStyle(fontSize: 17)),
          const Divider(thickness: 2),
          Table(
            columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1.7)},
            children: [
              TableRow(children: [
                _ReceiptCell(isBangla ? 'পণ্য' : 'Item', bold: true),
                _ReceiptCell(isBangla ? 'সংখ্যা' : 'Qty', bold: true, alignRight: true),
                _ReceiptCell(isBangla ? 'দর' : 'Rate', bold: true, alignRight: true),
                _ReceiptCell(isBangla ? 'মোট' : 'Total', bold: true, alignRight: true),
              ]),
              for (final item in items)
                TableRow(children: [
                  _ReceiptCell(item.name),
                  _ReceiptCell(_formatMoney(item.quantity), alignRight: true),
                  _ReceiptCell(_formatMoney(item.price), alignRight: true),
                  _ReceiptCell(_formatMoney(item.total), alignRight: true),
                ]),
            ],
          ),
          const Divider(thickness: 2),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(isBangla ? 'সর্বমোট' : 'TOTAL', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text('৳${_formatMoney(grandTotal)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 14),
          Text(isBangla ? 'ধন্যবাদ' : 'Thank you', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(isBangla ? 'আবার আসবেন' : 'Please visit again', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }

  static String _formatMoney(double value) => value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}

class _ReceiptCell extends StatelessWidget {
  const _ReceiptCell(this.text, {this.bold = false, this.alignRight = false});

  final String text;
  final bool bold;
  final bool alignRight;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(text, textAlign: alignRight ? TextAlign.right : TextAlign.left, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      );
}



