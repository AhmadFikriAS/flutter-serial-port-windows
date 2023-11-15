import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Serial Port Example'),
        ),
        body: SerialPortWidget(),
      ),
    );
  }
}

class SerialPortWidget extends StatefulWidget {
  @override
  _SerialPortWidgetState createState() => _SerialPortWidgetState();
}

class _SerialPortWidgetState extends State<SerialPortWidget> {
  SerialPort? _serialPort;
  final List<String> _logList = [];

  @override
  void initState() {
    super.initState();
    _setupSerialPort();
  }

  Future<void> _setupSerialPort() async {
    try {
      _serialPort = SerialPort('COM4',
          openNow: false, BaudRate: 9600, ByteSize: 8, StopBits: 1, Parity: 0);
      _serialPort?.open();
      _logList.add('Serial port opened successfully');
      _listenForData();
    } catch (e) {
      _logList.add('Error opening serial port: $e');
    }
    setState(() {});
  }

  void _listenForData() {
    _serialPort?.readOnListenFunction = (data) {
      String receivedData = String.fromCharCodes(data);
      setState(() {
        _logList.add('Received data: $receivedData');
      });
    };
  }

  Future<void> _sendData() async {
    String dataToSend = '*TRIG1#';
    try {
      _serialPort?.writeBytesFromString(dataToSend);
      setState(() {
        _logList.add('Sent data: $dataToSend');
      });
    } catch (e) {
      setState(() {
        _logList.add('Error sending data: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _logList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_logList[index]),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _sendData,
          child: Text('Send Data'),
        ),
      ],
    );
  }
}
