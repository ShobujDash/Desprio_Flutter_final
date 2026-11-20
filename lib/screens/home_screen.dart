import 'package:flutter/material.dart';

import 'invoice_screen.dart';
import 'management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static const green = Color(0xFF16834B);
  static const yellow = Color(0xFFFFC928);
  bool isBangla = true;
  int selectedTab = 0;

  String text(String bn, String en) => isBangla ? bn : en;

  Future<void> openInvoice() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InvoiceScreen(
          isBangla: isBangla,
          onLanguageToggle: () => setState(() => isBangla = !isBangla),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final title = text('দেশপ্রিয়', 'Deshpriyo');
    return Scaffold(key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFFDF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF6),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () => setState(() => isBangla = !isBangla),
            child: Text(isBangla ? 'English' : 'বাংলা',
                style: const TextStyle(color: green, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(text('আপনার ব্যবসার হিসাব', "Here's your business overview"),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Text(text('গত ৭ দিন', 'Last 7 Days')),
                  style: OutlinedButton.styleFrom(foregroundColor: green),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 144,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _metric(text('বিক্রি', 'Sales'), '৳0.00', const Color(0xFF70A781)),
                _metric(text('মোট লাভ', 'Profit (Gross)'), '৳0.00', green),
                _metric(text('নিট লাভ', 'Profit (Net)'), '৳0.00', const Color(0xFFB68A00)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Row(
                  children: [
                    _stat('0', text('কম স্টক', 'Low stock')),
                    _stat('0', text('খসড়া', 'Draft')),
                    _stat('0', text('সম্পন্ন', 'Completed')),
                    _stat('2', text('বাকি কাস্ট.', 'Due cust.')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: .82,
              children: [
                _shortcut(Icons.folder_copy_outlined, text('ক্যাটাগরি', 'Categories'), const Color(0xFFFFF3C4)),
                _shortcut(Icons.inventory_2_outlined, text('পণ্য', 'Products'), const Color(0xFFE7F7F1)),
                _shortcut(Icons.category_outlined, text('ভ্যারিয়েন্ট', 'Variants'), const Color(0xFFEAF5E9)),
                _shortcut(Icons.all_inbox_outlined, text('স্টক', 'Stocks'), const Color(0xFFFFF6E4)),
                _shortcut(Icons.person_outline, text('কাস্টমার', 'Customers'), const Color(0xFFE7F7F1)),
                _shortcut(Icons.receipt_long_outlined, text('ইনভয়েস', 'Invoices'), const Color(0xFFFFF3C4), onTap: openInvoice),
                _shortcut(Icons.payments_outlined, text('খরচ', 'Expenses'), const Color(0xFFEAF5E9)),
                _shortcut(Icons.bar_chart_outlined, text('রিপোর্ট', 'Reports'), const Color(0xFFFFF3C4)),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text('সাম্প্রতিক ইনভয়েস', 'Recent Invoices'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(backgroundColor: Color(0xFFFFF3E3), child: Icon(Icons.receipt, color: Colors.orange)),
                      title: Text(text('হাঁটা-চলা কাস্টমার', 'Walk-in Customer')),
                      subtitle: const Text('INV-20261014-0001'),
                      trailing: const Text('৳0.00', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(width: double.infinity, child: OutlinedButton(onPressed: openInvoice, child: Text(text('ইনভয়েস তৈরি করুন', 'Create Invoice')))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openInvoice,
        backgroundColor: yellow,
        foregroundColor: green,
        child: const Icon(Icons.add, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, text('হোম', 'Home'), 0),
              _navItem(Icons.receipt_long_outlined, text('ইনভয়েস', 'Invoice'), 1, onTap: openInvoice),
              const SizedBox(width: 48),
              _navItem(Icons.inventory_2_outlined, text('স্টক', 'Stock'), 2),
              _navItem(Icons.grid_view_rounded, text('আরও', 'More'), 3, onTap: () => _scaffoldKey.currentState?.openDrawer()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) => Drawer(
        backgroundColor: const Color(0xFFFFFDF6),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const CircleAvatar(backgroundColor: yellow, child: Icon(Icons.storefront, color: green)),
                title: Text(text('দেশপ্রিয়', 'Deshpriyo'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                subtitle: Text(text('দেশপ্রিয় মিষ্টান্ন ভাণ্ডার', 'Deshpriyo Sweets')),
                trailing: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ),
              const Divider(),
              _drawerItem(Icons.dashboard_outlined, text('ড্যাশবোর্ড', 'Dashboard')),
              _drawerItem(Icons.inventory_2_outlined, text('জমা (Store)', 'Store'), onTap: () => _openManagement(text('জমা (Store)', 'Store'), Icons.inventory_2_outlined)),
              _drawerGroup(Icons.shopping_cart_outlined, text('ক্রয় (Purchase)', 'Purchase'), [
                (Icons.list_alt, text('ক্রয় তালিকা', 'Purchase List')),
                (Icons.add_circle_outline, text('ক্রয় যোগ করুন', 'Add Purchase')),
              ]),
              _drawerGroup(Icons.account_balance_wallet_outlined, text('খরচ (Expense)', 'Expense'), [
                (Icons.list_alt, text('খরচ তালিকা', 'Expense List')),
                (Icons.add_circle_outline, text('খরচ যোগ করুন', 'Add Expense')),
              ]),
              _drawerGroup(Icons.shopping_bag_outlined, text('বিক্রয় (Sales)', 'Sales'), [
                (Icons.people_outline, text('খুচরা (Retail)', 'Retail')),
                (Icons.storefront_outlined, text('পাইকারি (Wholesale)', 'Wholesale')),
              ]),
              _drawerGroup(Icons.settings_outlined, text('সেটিংস (Settings)', 'Settings'), [
                (Icons.inventory_2_outlined, text('পণ্য যোগ করুন', 'Add Product')),
                (Icons.store_outlined, text('দোকান যোগ করুন', 'Add Shop')),
                (Icons.price_change_outlined, text('দাম পরিচালনা', 'Price Management')),
                (Icons.list_alt, text('দোকানভিত্তিক মূল্য তালিকা', 'Store Price List')),
              ]),
              const Divider(),
              _drawerItem(Icons.receipt_long_outlined, text('ইনভয়েস তৈরি', 'Create Invoice'), onTap: openInvoice),
              _drawerItem(Icons.people_outline, text('মানুষ', 'People'), onTap: () => _openManagement(text('মানুষ', 'People'), Icons.people_outline)),
              _drawerItem(Icons.bar_chart_outlined, text('রিপোর্ট', 'Reports'), onTap: () => _openManagement(text('রিপোর্ট', 'Reports'), Icons.bar_chart_outlined)),
              ListTile(leading: const Icon(Icons.logout, color: green), title: Text(text('লগ আউট', 'Logout'))),
            ],
          ),
        ),
      );

  Widget _drawerGroup(IconData icon, String label, List<(IconData, String)> items) => ExpansionTile(
        leading: Icon(icon, color: green),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        iconColor: green,
        collapsedIconColor: Colors.grey.shade700,
        childrenPadding: const EdgeInsets.only(left: 24),
        children: [for (final (itemIcon, itemLabel) in items) _drawerItem(itemIcon, itemLabel, onTap: () => _openManagement(itemLabel, itemIcon))],
      );

  void _openManagement(String title, IconData icon) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ManagementScreen(title: title, icon: icon, isBangla: isBangla),
    ));
  }

  Widget _drawerItem(IconData icon, String label, {VoidCallback? onTap}) => ListTile(
        leading: Icon(icon, color: green), title: Text(label), trailing: const Icon(Icons.chevron_right), onTap: () {
          Navigator.of(context).maybePop();
          onTap?.call();
        },
      );

  Widget _metric(String title, String value, Color color) => Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 23, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(height: 3, color: color.withValues(alpha: .7)),
        ]),
      );

  Widget _stat(String value, String label) => Expanded(
        child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontSize: 11))]),
      );

  Widget _shortcut(IconData icon, String label, Color bg, {VoidCallback? onTap}) => InkWell(
        borderRadius: BorderRadius.circular(18), onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
          padding: const EdgeInsets.all(8),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(backgroundColor: bg, child: Icon(icon, color: green)), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
        ),
      );

  Widget _navItem(IconData icon, String label, int index, {VoidCallback? onTap}) => InkWell(
        onTap: onTap ?? () => setState(() => selectedTab = index),
        child: SizedBox(width: 60, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: selectedTab == index ? green : Colors.grey.shade600), Text(label, style: TextStyle(fontSize: 10, color: selectedTab == index ? green : Colors.grey.shade700))])),
      );
}

