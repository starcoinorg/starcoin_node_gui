
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:starcoin_wallet/wallet/host_manager.dart';
import 'package:starcoin_wallet/wallet/node.dart';
// import 'package:starcoin_node/main.dart';
// import 'package:starcoin_wallet/wallet/host_manager.dart';
// import 'package:starcoin_wallet/wallet/node.dart';

void main() {
  Process process;

  setUp(() async {
    Directory current = Directory.current;
    var command = join(current.path, 'starcoin/starcoin.exe');
    process = await Process.start( command,  ["-n", "proxima",],  runInShell: false);
  });

  test('node rpc test', () async {
     final node = Node(SimpleHostManager(Set.from(["localhost"])));
     final account = await node.defaultAccount();
     expect(account.hashCode, 0);
  });

  tearDown(() async {
    if (process != null) {
      process.kill(ProcessSignal.sigquit);
      await process.exitCode;
    }
  });
}
