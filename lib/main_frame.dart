import 'package:flutter/material.dart';
//import 'package:get/get.dart';
import 'bluetooth_manager.dart';
import 'connect_frame.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MainFrame extends StatefulWidget {
  final BluetoothManager bluetoothManager;

  const MainFrame({Key? key, required this.bluetoothManager}) : super(key: key);

  @override
  _MainFrameState createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  bool _isBluetoothEnabled = false;
  List<BluetoothDevice> _devicesList = [];

  @override
  void initState() {
    super.initState();
    _isBluetoothEnabled = widget.bluetoothManager.bluetoothState.isEnabled;
    getBluetoothState();

    widget.bluetoothManager.addListener(updateDevicesList);
  }

  void updateDevicesList() {
    setState(() {
      _devicesList = widget.bluetoothManager.devicesList;
    });
  }

  @override
  void dispose() {
    widget.bluetoothManager.removeListener(updateDevicesList);
    super.dispose();
  }

  Future<void> getBluetoothState() async {
    final bluetoothState = await widget.bluetoothManager.bluetoothState;
    setState(() {
      _isBluetoothEnabled = bluetoothState.isEnabled;
    });
  }

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Enable Bluetooth:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FlutterSwitch(
                  activeText: "On",
                  inactiveText: "Off",
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.grey,
                  value: _isBluetoothEnabled,
                  onToggle: (value) {
                    setState(() {
                      _isBluetoothEnabled = value;
                    });
                    widget.bluetoothManager.onBluetoothChanged(value);
                  },
                ),
              ],
            ),
          ),
          if (_isBluetoothEnabled)
            Expanded(
              child: ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (context, index) {
                  BluetoothDevice device = _devicesList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.bluetooth),
                        title: Text(device.name!),
                        subtitle: Text(device.address),
                        onTap: () async {
//                          widget.bluetoothManager.reset(); // reiniciar  los valores
                          await widget.bluetoothManager.resetConnection();
                          widget.bluetoothManager.device = device;
                          await widget.bluetoothManager.connect(); // Conectar el dispositivo
                          widget.bluetoothManager.updateConnecDevice(device);


                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConnectFrame(
                                device: device,
                                bluetoothManager:  widget.bluetoothManager,
                                isConnected :  widget.bluetoothManager.connected,

                                onDisconnect: ()  {
                                  //widget.bluetoothManager.sendDisconnectionCommandToBluetooth();
                                  widget.bluetoothManager.reset();
                                  /*
                                  if(widget.bluetoothManager.connected){
                                    await widget.bluetoothManager.disconnect(); 
                                  }
                                  setState(() {
                                    widget.bluetoothManager.device =null;
                                    widget.bluetoothManager.showConnectFrame = false;
                                  });
                                  */
                                    setState(() {
                                      widget.bluetoothManager.showConnectFrame = false;
                                    });
                                },
                                onBack: (){
                                    //widget.bluetoothManager.sendDisconnectionCommandToBluetooth();
                                  setState(() {
                                    widget.bluetoothManager.showConnectFrame = false; 
                                  });
                                 // Navigator.pop(context);
                                }
                                
                              ),
                            ),
                          );

                          
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  "Bluetooth is currently off",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    child: Text("Bluetooth Settings"),
                    onPressed: () {
                      FlutterBluetoothSerial.instance.openSettings();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}