import 'package:flutter/material.dart';
import 'bluetooth_manager.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ConnectFrame extends StatefulWidget {
  final BluetoothDevice? device;
  final Function()? onDisconnect;
  final Function()? onBack;
  final BluetoothManager bluetoothManager;
  //final VoidCallback disconnectDevice;
  final bool isConnected;

  ConnectFrame({
    required this.device,
    required this.onDisconnect,
    required this.onBack,
    required this.bluetoothManager,
    required this.isConnected,
 //   required this.disconnectDevice,
  });

  @override
  _ConnectFrameState createState() => _ConnectFrameState();
}

class _ConnectFrameState extends State<ConnectFrame> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  bool isConnected = false;
  bool cardsEnabled = false; // Inicialmente deshabilitamos las cards

  @override
  void initState() {
    super.initState();
    isConnected = widget.bluetoothManager.connected;
    cardsEnabled = isConnected; // Inicialmente, las cards están habilitadas si el dispositivo está conectado
    bluetoothManager.addListener(updateConnectionStatus);
  }

  @override
  void dispose() {
    bluetoothManager.removeListener(updateConnectionStatus);
    super.dispose();
  }

  void updateConnectionStatus() {
    setState(() {
      isConnected = widget.bluetoothManager.connected;
      cardsEnabled = isConnected; // Habilitar/deshabilitar las cards según el estado de conexión
    });
  }

void onBack(){
  // Llamamamos al metodo reset() del bluetoothManager para reiniciar los valores
 // widget.bluetoothManager.reset();
  widget.bluetoothManager.sendDisconnectionCommandToBluetooth();
  //llamamos a la funcion onBack si esta definida
  widget.onBack?.call();
  setState(() {
    widget.bluetoothManager.showConnectFrame = false; 
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to ${widget.device?.name}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.bluetooth_disabled),
            onPressed: () {
              setState(() {
                widget.bluetoothManager.disableBluetooth();
                widget.bluetoothManager.sendDisconnectionCommandToBluetooth(); // Manda el codigo al microcontrolador de desconexion de dispositivos.
                //isConnected = false;
                Navigator.pop(context);  // Regresar al menu principal 
  //widget.onBack?.call();
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera card de configuracion
          Card(
            elevation: 8.0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  cardsEnabled = !cardsEnabled;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuration',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Status: ${widget.bluetoothManager.connected ? 'Connected' : 'Disconnected'}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IgnorePointer(
                          child: Switch(
                          value: widget.bluetoothManager.connected,
                          onChanged: (value) {
                            setState(() {
                              isConnected = value;
                              cardsEnabled = isConnected; // Habilitar/deshabilitar las cards según el estado de conexión
                              if (isConnected) {
                                widget.bluetoothManager.connected;
                              } else {
                                widget.bluetoothManager.disconnect;
                              }
                            });
                          },
                        ),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ),//
          ),

          //Segunda Card

          Opacity(
            opacity: cardsEnabled ? 1.0 : 0.5,
            child: Card(
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Control del LED',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: ElevatedButton(
                        onPressed: cardsEnabled ? () {
                          widget.bluetoothManager.sendOnMessageToBluetooth();
                        } : null, // Deshabilitar el botón si las cards están deshabilitadas
                        child: Text("On LED"),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: cardsEnabled ? () {
                          widget.bluetoothManager.sendOffMessageToBluetooth();
                        } : null, // Deshabilitar el botón si las cards están deshabilitadas
                        child: Text("OFF LED"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


          //Tercera Card

          Opacity(
            opacity: cardsEnabled ? 1.0 : 0.5,
            child: Card(
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Speed Control',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
    Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    IconButton(
      icon: Icon(Icons.arrow_downward),
      onPressed: cardsEnabled
          ? () {
              setState(() {
                // Disminuir el valor en 1, pero asegurarse de que esté restringido entre 0 y 9
                widget.bluetoothManager.speedValue =
                    (widget.bluetoothManager.speedValue - 1).clamp(0,9);
              });
              // Llamar a sendSpeedValueToBluetooth con el nuevo valor
              widget.bluetoothManager.sendSpeedValueToBluetooth();
            }
          : null, // Deshabilitar el botón si las cards están deshabilitadas
    ),
    IconButton(
      icon: Icon(Icons.arrow_upward),
      onPressed: cardsEnabled
          ? () {
              setState(() {
                // Aumentar el valor en 1, pero asegurarse de que esté restringido entre 0 y 9
                widget.bluetoothManager.speedValue =
                    (widget.bluetoothManager.speedValue + 1).clamp(0,9);
              });
              // Llamar a sendSpeedValueToBluetooth con el nuevo valor
              widget.bluetoothManager.sendSpeedValueToBluetooth();
            }
          : null, // Deshabilitar el botón si las cards están deshabilitadas
    ),
  ],
)

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
