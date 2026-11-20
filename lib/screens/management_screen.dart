import 'package:flutter/material.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key, required this.title, required this.icon, required this.isBangla});

  final String title;
  final IconData icon;
  final bool isBangla;

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  static const green = Color(0xFF16834B);
  static const yellow = Color(0xFFFFC928);
  final nameController = TextEditingController();
  final detailController = TextEditingController();
  final amountController = TextEditingController();

  String t(String bn, String en) => widget.isBangla ? bn : en;

  bool get isForm => widget.title.contains('যোগ') || widget.title.toLowerCase().startsWith('add ');
  bool get isPrice => widget.title.contains('দাম') || widget.title.contains('মূল্য') || widget.title.toLowerCase().contains('price');
  bool get isProduct => widget.title.contains('পণ্য') || widget.title.toLowerCase().contains('product');
  bool get isShop => widget.title.contains('দোকান') || widget.title.toLowerCase().contains('shop');
  bool get isExpense => widget.title.contains('খরচ') || widget.title.toLowerCase().contains('expense');

  @override
  void dispose() {
    nameController.dispose();
    detailController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFFFDF6),
        appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold))),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            if (isForm) _buildForm() else if (isPrice) _buildPriceView() else _buildListView(),
          ],
        ),
      );

  Widget _buildForm() => Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade200)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(isProduct ? t('পণ্যের তথ্য', 'Product details') : isShop ? t('দোকানের তথ্য', 'Shop details') : isExpense ? t('খরচের তথ্য', 'Expense details') : t('ক্রয়ের তথ্য', 'Purchase details'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 18),
            _field(nameController, isProduct ? t('পণ্যের নাম', 'Product name') : isShop ? t('দোকানের নাম', 'Shop name') : isExpense ? t('খরচের বিবরণ', 'Expense description') : t('সরবরাহকারী', 'Supplier')),
            const SizedBox(height: 12),
            if (isProduct || isShop) ...[
              _field(detailController, isProduct ? t('একক / বিবরণ', 'Unit / description') : t('ঠিকানা / ফোন', 'Address / phone')),
              const SizedBox(height: 12),
            ],
            _field(amountController, isProduct ? t('দাম (৳)', 'Price (৳)') : t('টাকার পরিমাণ (৳)', 'Amount (৳)'), number: true),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('নাম লিখুন', 'Enter a name'))));
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('ফর্মটি প্রস্তুত। সংরক্ষণে ডেটাবেস সংযোগ প্রয়োজন।', 'Form is ready. Connect a database to save this record.'))));
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(t('সংরক্ষণ করুন', 'Save')),
            ),
          ]),
        ),
      );

  Widget _buildPriceView() => Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade200)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(t('দোকানভিত্তিক পণ্যের দাম', 'Product prices by shop'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(decoration: InputDecoration(labelText: t('দোকান বাছাই করুন', 'Select shop'), border: const OutlineInputBorder()), items: [DropdownMenuItem(value: 'shop', child: Text(t('দোকান নির্বাচন', 'Choose a shop')))], onChanged: (_) {}),
            const SizedBox(height: 12),
            _field(nameController, t('পণ্যের নাম', 'Product name')),
            const SizedBox(height: 12),
            _field(amountController, t('মূল্য (৳/কেজি)', 'Price (৳/kg)'), number: true),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('দাম যোগ করতে ডেটাবেস সংযোগ প্রয়োজন।', 'Connect a database to save prices.')))), icon: const Icon(Icons.add), label: Text(t('মূল্য যোগ করুন', 'Add Price'))),
          ]),
        ),
      );

  Widget _buildListView() {
    final hint = widget.title.contains('তালিকা') || widget.title.toLowerCase().contains('list')
        ? t('এখনো কোনো তথ্য নেই', 'Nothing here yet')
        : t('এই অংশের তথ্য এখানে দেখা যাবে', 'Records for this section will appear here');
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 42),
        child: Column(children: [
          CircleAvatar(radius: 30, backgroundColor: const Color(0xFFFFF3C4), child: Icon(widget.icon, color: green, size: 28)),
          const SizedBox(height: 14),
          Text(hint, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17), textAlign: TextAlign.center),
          const SizedBox(height: 7),
          Text(t('তথ্য সংরক্ষণের জন্য ডেটাবেস সংযোগ প্রয়োজন।', 'Connect a database to store and display records.'), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 16),
          const Icon(Icons.circle, color: yellow, size: 8),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false}) => TextField(
        controller: controller,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      );
}
