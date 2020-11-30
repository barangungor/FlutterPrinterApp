import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        // channel: IOWebSocketChannel.connect('ws://188.132.148.79:9444'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  // final WebSocketChannel channel;

  MyHomePage({Key key, @required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  TextEditingController _controller = TextEditingController();
  InAppWebViewController webViewController;
  bool webview = false;
  var timerCount;
  bool netConnection;
  bool connection = false;
  final channel = IOWebSocketChannel.connect('ws://188.132.148.79:9944');
  Timer confirmTimer;
  Connectivity connectivity;
  StreamSubscription subNet;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectivity = Connectivity();
    subNet = connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile ||
          event == ConnectivityResult.wifi) {
        setState(() {
          netConnection = true;
        });
      } else {
        setState(() {
          netConnection = false;
        });
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    channel.sink.close();
    subNet.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        confirmTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (timer.tick == 5) {
            confirmTimer.cancel();
            // webViewController.loadData(data: '<h1>SÜRE DOLDU!</h1>');
            channel.sink.add(json
                .encode({"signalName": 'exitSession', "connectionId": '10'}));
            channel.sink.close();
          }
        });
        break;
      case AppLifecycleState.resumed:
        confirmTimer.cancel();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: webview == true
          ? Column(
              children: [
                Container(
                  height: 500,
                  child: InAppWebView(
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                      webViewController.loadData(
                          data: '<h1>ÖDEME SAYFASI</h1>');
                    },
                  ),
                )
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Send a message'),
                  ),
                ),
                RaisedButton(
                  child: Text('Gönder'),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
                netConnection == true
                    ? StreamBuilder(
                        stream: channel.stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.active &&
                              connection == false) {
                            channel.sink.add(json.encode({
                              "signalName": 'openConnection',
                              "connectionId": '10'
                            }));
                            connection = true;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(snapshot.hasData
                                ? '${json.decode(snapshot.data)['message']}'
                                : ''),
                          );
                        },
                      )
                    : Text('Internet Bağlantınızı Kontrol Ediniz..')
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            webview = !webview;
          });
        },
        child: Icon(Icons.cached),
      ),
    );
  }

  _sendMessage() {
    // if (_controller.text.isNotEmpty) {

    channel.sink
        .add(json.encode({"signalName": 'exitSession', "connectionId": '10'}));
    // }
  }
}
