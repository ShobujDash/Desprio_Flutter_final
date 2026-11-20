import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

class PrinterService {
  Future<BluetoothDevice?> selectPrinter(BuildContext context) {
    return FlutterBluetoothPrinter.selectDevice(context);
  }

  Future<bool> printReceipt({
    required ReceiptController controller,
    required String address,
    void Function(int total, int sent)? onProgress,
  }) async {
    try {
      return await controller.print(
        address: address,
        addFeeds: 4,
        keepConnected: false,
        onProgress: onProgress,
      );
    } catch (error) {
      debugPrint('Print Error: $error');
      return false;
    }
  }

  Future<void> disconnect(String address) async {
    await FlutterBluetoothPrinter.disconnect(address);
  }
}
