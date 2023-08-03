import 'package:app2/bluetooth_manager.dart';
import 'package:flutter/material.dart';
import 'bluetooth_app.dart';

void main() {
  runApp(const MyApp());
  BluetoothManager bluetoothManager = BluetoothManager();
  bluetoothManager.initBluetooth();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothApp(),
    );
  }
}
