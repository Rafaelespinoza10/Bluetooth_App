import 'dart:async';
import 'dart:convert';
//import 'dart:js_util';
//import 'dart:js';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


class BluetoothManager extends ChangeNotifier {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
 final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  	BuildContext? context;

  int _deviceState = 0; // neutral
  bool _isButtonUnavailable = false;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool isDisconnecting = false;
  bool _showConnectFrame = false;
  bool _isConnectingDevice = false; // variable para rastrear si el dispositivo se encuentra conectado
  int speedValue = 0;                // Propiedad para almacenar el valor de la velocidad del motor (0 a 255)


  bool get isConnectingDevice => _isConnectingDevice;
  set isConnectingDevice(bool value) => _isConnectingDevice = value;

  bool get showConnectFrame => _showConnectFrame;
  set showConnectFrame(bool value) => _showConnectFrame = value;

  BluetoothDevice? get device => _device;
  set device(BluetoothDevice? value) => _device = value;

  BluetoothState get bluetoothState => _bluetoothState;

  List<BluetoothDevice> get devicesList => _devicesList;

  int get deviceState => _deviceState;

  bool get connected => _connected;

  bool get isButtonUnavailable => _isButtonUnavailable;

 BluetoothConnection? get connection => _connection;

  int get _speedValue => speedValue;
  set _speedValue(int value){
      if(_speedValue != value){
        _speedValue = value;

        if(connected){
          sendSpeedValueToBluetooth();
        }
      }
  } 



  void init(BuildContext context){
    this.context = context;
  }

  
  @override
  void dispose() {
    if (_connected) {
      isDisconnecting = true;
      _connection?.dispose();
      _connection = null;
    }
    super.dispose();
  }


  Future<void> initBluetooth() async {
    _bluetoothState = await _bluetooth.state;
   // _bluetoothState.onStateChanged().listen
   //_isBluetoothEnabled = _bluetoothState == BluetoothState.STATE_ON; 
   // getPairedDevices();
    //enableBluetooth();
  bool? isBluetoothEnabled = await FlutterBluetoothSerial.instance.isEnabled;
   

   if(isBluetoothEnabled ?? false){
 //   showMessage('Please enable Bluetooth in your device setting ');
    return; 
   }
    _bluetooth.onStateChanged().listen((BluetoothState state) {
      _bluetoothState =state;
    if(_bluetoothState ==BluetoothState.STATE_OFF){
      _isButtonUnavailable = true;
    }
     // _bluetoothState = _bluetoothState = BluetoothState.STATE_ON;
     getPairedDevices();
     // notifyListeners();
    });
    getPairedDevices();
  }


/*
Future < void> waitForBluetoothEnabled() async{
  while(_bluetoothState!= BluetoothState.STATE_ON){
    await Future.delayed(Duration(milliseconds: 500));
    _bluetoothState = await _bluetooth.state;
  }
}

*/
  

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await _bluetooth.getBondedDevices();
    } catch (error) {
      print("Error: $error");
    }  

    //Store the[Devices] list in the {_deviceslist}
    //the list outside this class
    _devicesList = devices;

    //Notify listeners that the devices list has changed
    notifyListeners();
  }

  Future<void> connect() async {
if (_isButtonUnavailable) {
      return;
    }

    if (_device == null) {
      showMessage('No device selected');
      return;
    }

    _isButtonUnavailable = true;

    try {
      if (!_connected) {
        _connection = await BluetoothConnection.toAddress(_device!.address);
        print('Connected to the device');
        _connected = true;

        _connection?.input?.listen((Uint8List data) {
          print('Data received: ${utf8.decode(data)}');
        }).onDone(() {
          if (isDisconnecting) {
            print('Disconnecting locally!');
          } else {
            print('Disconnected remotely!');
          }
          _connected = false;
          _connection = null;
        });
      } else {
        showMessage('Already connected to a device');
      }
    } catch (error) {
      showMessage('Cannot connect, exception occurred');
      print(error);
      showMessage('Cannot connect, exception occurred: $error');
  }

    _isButtonUnavailable = false;
    notifyListeners(); // Notificar los cambios en el estado
  }

  Future<void> disconnect() async {
    
  if (!_connected) {
    print('No device connected');
    return;
  }

  _isButtonUnavailable = true;
  _deviceState = 0;

  try {
    await _connection?.close();
    showMessage('Device disconnected');
  } catch (error) {
    print('Error while disconnecting: $error');
    showMessage('Error while disconnecting: $error');
  } finally {
    _connected = false;
    _connection = null;
    _isButtonUnavailable = false;
    notifyListeners(); // Notificar los cambios en el estado
  }

  }

  Future<void> sendOnMessageToBluetooth() async {
    if(_connection != null ){


    // Enviar el valor correspondiente al caracter E (encendido)
    Uint8List data = Uint8List.fromList(utf8.encode("E"));
    _connection?.output.add(data);
    await _connection?.output.allSent;
    _deviceState = 1; // dispositivo encendido

    }
  }

  Future<void> sendOffMessageToBluetooth() async {
   if(_connection != null){

    // Enviar el valor correspondiente al caracter A  (apagado)
    Uint8List data = Uint8List.fromList(utf8.encode("A"));
    _connection?.output.add(data);
    await _connection?.output.allSent;
    _deviceState = -1; // dispositivo apagado
   }
  }



 /// Control de velocidad del motor
  
  Future<void> sendSpeedValueToBluetooth() async{
    if(_connection != null ){
      //Enviar el valor correspondiente al byte 
      
      if(speedValue < 0 ){
        speedValue = 0;
      }else if(speedValue > 9){
        speedValue = 9;
      }

       Uint8List data = Uint8List.fromList(  utf8.encode(speedValue.toString()));
      _connection?.output.add(data);
     // _connection!.output.allSent.then((_) {

       // _deviceState = speedValue;
       // notifyListeners();
     // });

     await _connection?.output.allSent;
      
    }
  }




  
  void showMessage(String message) {
    if(context == null){
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );

    }
  }


  Future<void> onBluetoothChanged(bool value) async {
    //luetoothEnabled = value; 
  _isButtonUnavailable = true; 

    if (value) {
      await enableBluetooth();
//      _isBluetoothSwitchOn = true; //Actualiza el estado del switch 
    } else{
      await disableBluetooth();
  //    _isBluetoothSwitchOn = false; // Actualiza el estado del switch
    }
    _isButtonUnavailable = false; 
    notifyListeners();
  }

Future<void> enableBluetooth() async {
  // Retrieving the current Bluetooth state
  _bluetoothState = await FlutterBluetoothSerial.instance.state;

  // If the bluetooth is off, then turn it on first
  // and then retrieve the devices that are paired.
  if (_bluetoothState == BluetoothState.STATE_OFF) {
    bool? isBluetoothEnabled = await FlutterBluetoothSerial.instance.requestEnable();
    if (isBluetoothEnabled ?? false) {
      await getPairedDevices();
    } else {
      throw Exception('Bluetooth could not be enabled');
    }
  } else {
    await getPairedDevices();
  }
  notifyListeners();
}

  Future<void> disableBluetooth() async {
    try{
      await FlutterBluetoothSerial.instance.requestDisable();
      //_isBluetoothEnabled = false; 
      _connected = false;
      _device = null;
      //setBluetoothEnabled(false);
  //    _devicesList.clear();
    //  notifyListeners();
    }catch(error){
      print('error disabling bluetooth: $error');
    }
  }
  void reset(){
    // Cerrar la conexion si esta conectada
    if(_connected){
      disconnect();
    }

    //restablecer las variables y estados.
    _device =null;
    _connected = false;
    _isButtonUnavailable = false;
    _deviceState = 0;
    _isConnectingDevice = false;

    notifyListeners();
  }


void updateConnecDevice(BluetoothDevice device){
   _device = device; 
}

// Establecer conexion y desconexcion del dispositivo conectado
  Future<void> resetConnection() async{
    // Primero nos desconectamos del dispositivo
    if(_connection!=null && _connection !.isConnected){
      await _connection!.finish();
    }
      _connection = null;
      _device = null;
      _isConnectingDevice = false; 

  // Desconexion de los componenetes cuando la desconexion finaliza

  }

    void sendDisconnectionCommandToBluetooth() async{
//    if(_connection != null && _connection!.isConnected){
         Uint8List data = Uint8List.fromList(utf8.encode("D"));
      _connection?.output.add(data);
      await _connection?.output.allSent;
   // }
  }

}
