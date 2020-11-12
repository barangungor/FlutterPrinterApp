import 'dart:typed_data';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:oktoast/oktoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Bluetooth demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Bluetooth demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    super.initState();
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            print('BLUETOOTH ACIK');
            return Text('Bluetooth is active.');
          } else {
            print('BLUETOOTH KAPALI');
            return Text('Bluetooth is inactive.');
          }
        });
    // setState(() {
    //   _devices = [];
    // });
    // printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  Future<Ticket> voucherDatas(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);

    // Print image
    final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image image = decodeImage(bytes);
    // ticket.image(image);
    // ticket.text('Zu Hause sind Wir.',
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //     ),
    //     linesAfter: 1);
    // final now = DateTime.now();
    // final formatter = DateFormat('MM/dd/yyyy H:mm');
    // final String timestamp = formatter.format(now);
    // ticket.text(timestamp,
    //     styles: PosStyles(align: PosAlign.center), linesAfter: 1);
    // ticket.text('Hello & Goodbye', styles: PosStyles(align: PosAlign.center));
    // ticket.text('Herr Andreas Haase',
    //     styles: PosStyles(align: PosAlign.center));
    // ticket.text('Bernhard-Nocht-Straße 51',
    //     styles:
    //         PosStyles(align: PosAlign.center, codeTable: PosCodeTable.eastEur));
    // ticket.text('20359 Hamburg',
    //     styles: PosStyles(align: PosAlign.center), linesAfter: 1);
    // ticket.text('1907',
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ),
    //     linesAfter: 1);
    // ticket.text('Zustelltermin: heute Mittwoch, 21.10.20',
    //     styles: PosStyles(align: PosAlign.center));
    // ticket.text('17.00  18.30 Uhr', styles: PosStyles(align: PosAlign.center));
    // ticket.text('Product Quantity', styles: PosStyles(align: PosAlign.center));

    // ticket.hr(len: 42);
    // ticket.row([
    //   PosColumn(text: '3x', width: 1),
    //   PosColumn(text: 'salatasaray', width: 5),
    //   PosColumn(text: '0.05', width: 3),
    //   PosColumn(text: ' 0.15', width: 3),
    // ]);
    ticket.row([
      PosColumn(
          text: 'Zwischensumme ß',
          width: 6,
          styles: PosStyles(
              height: PosTextSize.size2, codeTable: PosCodeTable.westEur)),
      PosColumn(width: 1),
      PosColumn(
          text: '0.15',
          width: 5,
          styles:
              PosStyles(align: PosAlign.right, codeTable: PosCodeTable.eastEur))
    ]);
    // ticket.row([
    //   PosColumn(
    //       text: 'Lieferkosten',
    //       width: 6,
    //       styles: PosStyles(align: PosAlign.left, height: PosTextSize.size2)),
    //   PosColumn(width: 1),
    //   PosColumn(
    //       text: 'Gratis',
    //       width: 5,
    //       styles:
    //           PosStyles(align: PosAlign.right, codeTable: PosCodeTable.westEur))
    // ]);
    // ticket.row([
    //   PosColumn(
    //       text: 'Gesamt',
    //       width: 6,
    //       styles: PosStyles(height: PosTextSize.size2)),
    //   PosColumn(width: 1),
    //   PosColumn(
    //       text: String.fromCharCode(0128) + ' 0.15',
    //       width: 5,
    //       styles:
    //           PosStyles(align: PosAlign.right, codeTable: PosCodeTable.eastEur))
    // ]);
    // ticket.hr(len: 42, linesAfter: 1);
    // ticket.text('Anmerkungen:', styles: PosStyles(align: PosAlign.center));
    // ticket.text('1. OG rechts bei Haase klingeln');
    // ticket.hr(len: 42, linesAfter: 1);
    ticket.cut();
    return ticket;
  }

  void _printVoucher(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    const PaperSize paper = PaperSize.mm80;
    await printerManager.printTicket(await voucherDatas(paper));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => _printVoucher(_devices[index]),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name ?? ''),
                              Text(_devices[index].address),
                              Text(
                                'Click to print a test receipt',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            );
          }),
      floatingActionButton: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            print('*********');
            print(state);
            print('---------');
            FlutterBlue.instance.isOn.then((value) => print(value));
            print('*********');
            if (state == BluetoothState.on) {
              return FloatingActionButton(
                child: Icon(Icons.bluetooth),
                onPressed: _stopScanDevices,
                backgroundColor: Colors.green,
              );
            } else {
              return FloatingActionButton(
                child: Icon(Icons.bluetooth_disabled),
                onPressed: _stopScanDevices,
                backgroundColor: Colors.red,
              );
            }
          }),
    );
  }
}
