import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hex/hex.dart';
import 'package:starcoin_node/pages/account_manage_page.dart';
import 'package:starcoin_node/pages/popups.dart';
import 'package:starcoin_wallet/starcoin/starcoin.dart';
import 'package:starcoin_wallet/wallet/host_manager.dart';
import 'package:starcoin_wallet/wallet/node.dart';
import 'dart:io';
import 'dart:convert';
import 'constant.dart';
import 'directory_service.dart';
import 'localizations.dart';
import 'routes/routes.dart';
import 'package:date_format/date_format.dart';
import "package:path/path.dart" show join;
import 'package:image/image.dart' as img;

class NodePage extends StatefulWidget {
  static const String routeName = Routes.main + "/index";

  String userName;

  NodePage(this.userName);

  @override
  State createState() {
    return new _NodePageState(this.userName);
  }
}

class _NodePageState extends State<NodePage> with TickerProviderStateMixin {
  Process process;
  String _processConsoleText = "";
  double balance = 0;
  String difficulty = "0";
  int blocks = 0;
  int maxLines = 10;
  String time = "";
  List<String> lines = [];
  String address = "0x00000000000000000000000000000000";
  String taskName = "";
  String percent = "";

  String userName;

  GlobalKey previewContainer = new GlobalKey();

  _NodePageState(this.userName);

  bool startRequest = false;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  // void scrollToBottom() {
  //  _scrollController.animateTo(
  //     _scrollController.position.maxScrollExtent,
  //     duration: Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final double iconSize = 60.0;
    final double buttonIconSize = 40.0;
    final blue = Color.fromARGB(255, 0, 255, 255);

    final blueTextstyle = TextStyle(color: blue, fontSize: 18);
    final whiteTextstyle = TextStyle(color: Colors.white, fontSize: 18);
    final edgeTexts = EdgeInsets.only(left: 30, right: 30);
    final dateTime = DateTime.now();
    time = formatDate(dateTime, [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn]);
    freshTime();
    final boxDecoration = new BoxDecoration(
      //设置四周圆角 角度
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      //设置四周边框
      border: new Border.all(width: 1, color: blue),
    );
    var onclick;
    if (!startRequest) {
      onclick = () async {
        var command = "";
        File file;
        if (Platform.isMacOS) {
          final current = await DirectoryService.getCurrentDirectory();
          final dir = Directory.fromUri(Uri.parse(current));
          command = join(dir.path, 'Contents/Resources/starcoin');
          file = File(command);
          //command = 'Contents/Resources/starcoin';
        }
        if (Platform.isWindows) {
          Directory current = Directory.current;
          command = join(current.path, 'starcoin/starcoin.exe');
          file = File(command);
        }

        if (!await file.exists()) {
          // 文件不存在，显示警告对话框
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(StarcoinLocalizations.of(context).alertTitle),
                content: Text(StarcoinLocalizations.of(context).fileNotFound +
                    '$command'),
                actions: <Widget>[
                  TextButton(
                    child: Text(StarcoinLocalizations.of(context).confirm),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }

        process = await Process.start(
            command,
            [
              "-n",
              "proxima",
              "--http-apis",
              "all",
              "--disable-ipc-rpc",
              // "--push-server-url",
              // "http://miner-metrics-pushgw.starcoin.org:9191/",
              // "--push-interval",
              // "5"
              //"--disable-mint-empty-block",
              //"false"
            ],
            runInShell: false);
        process.stderr.transform(utf8.decoder).listen((data) {
          lines.add(data);
          if (data.contains("Mint new block")) {
            blocks++;
          }
          String tmpText;
          if (lines.length < maxLines) {
            tmpText = lines.join();
          } else {
            tmpText = lines.sublist(lines.length - maxLines).join();
          }
          setState(() {
            _processConsoleText = tmpText;
          });
        });
        startRequest = true;
        await freshData();
      };
    }

    var startButton = RaisedButton(
      padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 30, right: 30),
      color: blue,
      child: Image.asset(
        "assets/images/starcoin-start-mint.png",
        width: buttonIconSize,
        height: buttonIconSize,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(20.0),
        side: BorderSide(color: blue),
      ),
      onPressed: onclick,
    );

    var onStop;

    if (startRequest) {
      onStop = () {
        process.kill(ProcessSignal.sigterm);
        setState(() {
          _processConsoleText = "";
          blocks = 0;
          startRequest = false;
        });
      };
    }
    var stopButton = Container(
      padding: EdgeInsets.all(10),
      child: RaisedButton(
        color: blue,
        padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 30, right: 30),
        //borderSide: new BorderSide(color: blue),
        child: Image.asset(
          "assets/images/starcoin-stop-mint.png",
          width: buttonIconSize,
          height: buttonIconSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20.0),
          side: BorderSide(color: blue),
        ),
        onPressed: onStop,
      ),
    );
    return RepaintBoundary(
        key: previewContainer,
        child: Scaffold(
            body: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/starcoin-bg-bn.png"),
                        fit: BoxFit.cover)),
                child: Container(
                    margin: EdgeInsets.all(20),
                    decoration: new BoxDecoration(
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      //设置四周边框
                      border: new Border.all(
                          width: 1, color: Color.fromARGB(120, 0, 255, 255)),
                    ),
                    child: Column(children: <Widget>[
                      Row(children: <Widget>[
                        Image.asset(
                          'assets/images/starcoin-logo-fonts.png',
                          width: 200,
                        ),
                        Image.asset(
                          'assets/images/starcoin-miner.png',
                          width: 50,
                        ),
                        Column(children: <Widget>[
                          Text(StarcoinLocalizations.of(context).slogan,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                          Text(
                              StarcoinLocalizations.of(context)
                                      .officialWebsite +
                                  ': starcoin.org',
                              style: TextStyle(color: blue, fontSize: 15)),
                        ]),
                        Expanded(
                            flex: 1,
                            child: Container(alignment: Alignment.centerRight)),
                        Column(children: <Widget>[
                          Tooltip(
                              message:
                                  StarcoinLocalizations.of(context).privateKey,
                              child: IconButton(
                                  icon: Image.asset(
                                      'assets/images/starcoin-save-pk.png'),
                                  iconSize: 60,
                                  onPressed: () async {
                                    if (!startRequest) {
                                      await showSnackBar(
                                          context,
                                          StarcoinLocalizations.of(context)
                                              .nodeNotRun);
                                    } else {
                                      await savePrivateKey();
                                    }
                                  })),
                        ]),
                        Column(children: <Widget>[
                          Tooltip(
                              message: StarcoinLocalizations.of(context)
                                  .generatePoster,
                              child: IconButton(
                                  icon: Image.asset(
                                      'assets/images/starcoin-save.png'),
                                  iconSize: 60,
                                  onPressed: () async {
                                    await btnAction_TakeScreenshot();
                                  })),
                        ]),
                        Column(children: <Widget>[
                          Tooltip(
                              message: StarcoinLocalizations.of(context)
                                  .accountManage,
                              child: IconButton(
                                  icon: Icon(Icons.person),
                                  color: blue,
                                  iconSize: 40,
                                  onPressed: () async {
                                    if (!startRequest) {
                                      await showSnackBar(
                                          context,
                                          StarcoinLocalizations.of(context)
                                              .nodeNotRun);
                                      return;
                                    }
                                    await btnAction_popupAccountManagePage(
                                        context, address);
                                  })),
                        ]),
                        //   Expanded(
                        //       flex: 2,
                        //       child: Container(
                        //           //margin: EdgeInsets.only(left: 20),
                        //           alignment: Alignment.centerRight,
                        //           child: Tooltip(
                        //               message: StarcoinLocalizations.of(context)
                        //                   .privateKey,
                        //               child: IconButton(
                        //                 icon: Image.asset(
                        //                     'assets/images/starcoin-save-pk.png'),
                        //                 iconSize: 60,
                        //                 onPressed: () async {
                        //                   if (!startRequest) {
                        //                     final snackBar = SnackBar(
                        //                       content: Text(
                        //                           StarcoinLocalizations.of(
                        //                                   context)
                        //                               .nodeNotRun),
                        //                     );
                        //                     Scaffold.of(context)
                        //                         .showSnackBar(snackBar);
                        //                   } else {
                        //                     await savePrivateKey();
                        //                   }
                        //                 },
                        //               )))),
                        //   Expanded(
                        //       flex: 1,
                        //       child: Container(
                        //           margin: EdgeInsets.only(right: 20),
                        //           alignment: Alignment.centerRight,
                        //           child: Tooltip(
                        //               message: StarcoinLocalizations.of(context)
                        //                   .generatePoster,
                        //               child: IconButton(
                        //                 icon: Image.asset(
                        //                     'assets/images/starcoin-save.png'),
                        //                 iconSize: 60,
                        //                 onPressed: () async {
                        //                   await takescrshot();
                        //                 },
                        //               )))),
                        // ],
                      ]),
                      Container(
                        margin: EdgeInsets.only(left: 160, top: 10, right: 150),
                        alignment: Alignment(0, 0),
                        child: Center(
                            child: Column(children: <Widget>[
                          Row(children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  StarcoinLocalizations.of(context)
                                          .currentTask +
                                      "：$taskName",
                                  style: TextStyle(color: blue, fontSize: 13),
                                )),
                            Container(
                                margin: EdgeInsets.only(bottom: 10, left: 10),
                                child: Text(
                                  StarcoinLocalizations.of(context).progress +
                                      "：$percent%",
                                  style: TextStyle(color: blue, fontSize: 13),
                                )),
                            Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      time,
                                      style:
                                          TextStyle(color: blue, fontSize: 13),
                                    )))
                          ]),
                          Container(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 10, bottom: 10),
                              decoration: new BoxDecoration(
                                color: blue,
                                //设置四周圆角 角度
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                //设置四周边框
                                border: new Border.all(width: 1, color: blue),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    userName,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Container(
                                      padding: edgeTexts, child: Text(address))
                                ],
                              )),
                          SizedBox(height: 5),
                          Container(
                              decoration: boxDecoration,
                              child: Row(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/starcoin-balance.png',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                  Text(
                                    StarcoinLocalizations.of(context).balance,
                                    style: blueTextstyle,
                                  ),
                                  Container(
                                      padding: edgeTexts,
                                      child: Text("$balance",
                                          style: whiteTextstyle)),
                                  Text("STC", style: blueTextstyle)
                                ],
                              )),
                          SizedBox(height: 5),
                          Container(
                              decoration: boxDecoration,
                              child: Row(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/starcoin-block-number.png',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                  Text(
                                    StarcoinLocalizations.of(context)
                                        .minedBlocks,
                                    style: blueTextstyle,
                                  ),
                                  Container(
                                      padding: edgeTexts,
                                      child: Text("$blocks",
                                          style: whiteTextstyle)),
                                  Text(
                                      StarcoinLocalizations.of(context)
                                          .blockUnit,
                                      style: blueTextstyle)
                                ],
                              )),
                          SizedBox(height: 5),
                          Container(
                              decoration: boxDecoration,
                              child: Row(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/starcoin-difficulty.png',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                  Text(
                                      StarcoinLocalizations.of(context)
                                          .currentDiff,
                                      style: blueTextstyle),
                                  Container(
                                      padding: edgeTexts,
                                      child: Text(difficulty,
                                          style: whiteTextstyle))
                                ],
                              )),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[startButton, stopButton],
                          ),
                          // Container(
                          //     padding: EdgeInsets.all(4),
                          //     //decoration: boxDecoration,
                          //     color: Colors.green,
                          //     height: double.infinity,
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       children: <Widget> [
                          //         buildSelectedTextItem(Colors.red),
                          //         buildSelectedTextItem(Colors.green),
                          //         buildSelectedTextItem(Colors.blue),
                          //       ],
                          //     )
                          // )
                          new Text(
                            _processConsoleText,
                            style: TextStyle(color: Colors.white),
                            maxLines: maxLines,
                          ),
                        ])),
                      )
                    ])))));
  }

  void freshTime() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      final dateTime = DateTime.now();
      setState(() {
        time = formatDate(dateTime, [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn]);
      });
    });
  }

  void freshData() async {
    await Future.delayed(Duration(seconds: 5));
    final node = Node(SimpleHostManager(Set.from([LOCALURL])));
    Timer.periodic(Duration(seconds: 10), (timer) async {
      if (startRequest) {
        final account = await node.defaultAccount();
        final address =
            AccountAddress.fromJson(account['address'].replaceAll("0x", ""));
        final balance = await node.balanceOfStc(address);
        final nodeInfo = await node.nodeInfo();
        final totalDifficulty = nodeInfo['peer_info']['chain_info']
            ['block_info']['total_difficulty'];

        final syncProgress = await node.syncProgress();
        var taskNames;
        var percent = "0.00";
        if (syncProgress != null) {
          taskNames = syncProgress['current']['task_name'].split("::");
          percent = syncProgress['current']['percent']?.toStringAsFixed(2);
        }

        setState(() {
          this.address = address.toString();
          this.balance = balance.toBigInt() / BigInt.from(1000000000);
          this.difficulty = totalDifficulty;
          if (taskNames != null)
            this.taskName = taskNames[taskNames.length - 1];
          this.percent = percent;
        });
      }
    });
  }

  Widget buildSelectedTextItem(Color color) {
    return Expanded(
      child: Container(
        height: double.infinity,
        color: color,
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Text(
              "1132131",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  btnAction_TakeScreenshot() async {
    RenderRepaintBoundary boundary =
        previewContainer.currentContext.findRenderObject();
    var image = await boundary.toImage();
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();
    img.Image background = img.decodeImage(pngBytes);

    var filePath;
    if (Platform.isMacOS) {
      final current = await DirectoryService.getCurrentDirectory();
      final dir = Directory.fromUri(Uri.parse(current)).path;
      filePath = join(dir, 'Contents/Resources/starcoin-qr.png');
    }
    if (Platform.isWindows) {
      Directory current = Directory.current;
      final dir = current.path;
      filePath = join(dir, 'starcoin/starcoin-qr.png');
    }
    final qrFile = File(filePath);

    img.Image qr = img.decodeImage(qrFile.readAsBytesSync());

    img.drawImage(background, qr, dstX: 40, dstY: 450, dstH: 120, dstW: 120);

    int fileName = DateTime.now().microsecondsSinceEpoch;

    var dir;
    if (Platform.isMacOS) {
      final current = await DirectoryService.getCurrentDirectory();
      dir = Directory.fromUri(Uri.parse(current)).parent.path;
    }
    if (Platform.isWindows) {
      Directory current = Directory.current;
      dir = current.path;
    }

    var path = join(dir, '$fileName.png');
    // //final file = File(path);
    // //await file.writeAsBytes(wmImage);
    File(path)..writeAsBytesSync(img.encodePng(background));
  }

  savePrivateKey() async {
    final node = Node(SimpleHostManager(Set.from([LOCALURL])));
    final account = await node.defaultAccount();
    if (account == null) {
      return;
    }
    final List exportedAccount =
        await node.exportAccount(account['address'], "");
    if (exportedAccount == null) {
      return;
    }
    final String hexPrivatekey =
        "0x" + HEX.encode(exportedAccount.map((e) => e as int).toList());

    var dir;
    if (Platform.isMacOS) {
      final current = await DirectoryService.getCurrentDirectory();
      dir = Directory.fromUri(Uri.parse(current)).parent.path;
    }
    if (Platform.isWindows) {
      Directory current = Directory.current;
      dir = current.path;
    }

    var path = join(dir, 'private_key.txt');
    File(path)..writeAsStringSync(hexPrivatekey);
  }
}

btnAction_popupAccountManagePage(
    BuildContext context, String defaultAccount) async {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            AccountManagerPage(defaultAccount: defaultAccount)),
  );
}
