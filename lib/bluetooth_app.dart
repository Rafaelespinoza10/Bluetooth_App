import 'package:flutter/material.dart';
import 'bluetooth_manager.dart';
import 'connect_frame.dart';
import 'main_frame.dart';
//import 'package:provider/provider.dart';

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({Key? key}) : super(key: key);

  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
 
  late BluetoothManager _bluetoothManager;
  bool _isBluetoothEnabled = false; 
//  late _SnackBarManager _snackBarManager;
  final BluetoothManager bluetoothManager = BluetoothManager();


  @override
  void initState() {
    super.initState();
    _bluetoothManager = BluetoothManager();
    _bluetoothManager.init(context);    //Pasa el buildContext al Bluetoothmanager pa.
    _bluetoothManager.initBluetooth(); //llama el metodo  para inicializar el bluetooth
    setState(() {
      _isBluetoothEnabled = _bluetoothManager.isButtonUnavailable;
    });
  //  _snackBarManager = _SnackBarManager(child: Container());
  }


void disconnectDevice(){
  if(_bluetoothManager.connected){
        _bluetoothManager.disconnect();
  }
}


  @override
  void dispose() {
    _bluetoothManager.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return _SnackBarManager(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          backgroundColor: Colors.blueAccent,
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                await _bluetoothManager.getPairedDevices().then((_) {
                  _bluetoothManager.showMessage('Device list refreshed');
                });
              },
            ),
          ],
        ),
        body: _bluetoothManager.isConnectingDevice
            ? ConnectFrame(
                device: _bluetoothManager.device,
                bluetoothManager: _bluetoothManager,
                isConnected: _bluetoothManager.connected,
                onDisconnect: () {
                //  _bluetoothManager.disconnect();
                  _bluetoothManager.reset();
                  setState(() {
                  //  _bluetoothManager.device = null;
                    _bluetoothManager.showConnectFrame = false;
                 
                  });
                },
                onBack: () {
                 // _bluetoothManager.sendDisconnectionCommandToBluetooth();
                  setState(() {
           //         _bluetoothManager.sendDisconnectionCommandToBluetooth();
                    _bluetoothManager.showConnectFrame = false;
                  });
                },
              )
            : MainFrame(
                bluetoothManager: _bluetoothManager,
              ),
      ),
    );
    
  }
}


 
class _SnackBarManager extends StatefulWidget {
  final Widget child;

  const _SnackBarManager({required this.child});

  @override
  __SnackBarManagerState createState() => __SnackBarManagerState();

  static __SnackBarManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<__SnackBarManagerState>();
  }
}

class __SnackBarManagerState extends State<_SnackBarManager> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}