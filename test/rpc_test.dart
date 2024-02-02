import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:starcoin_wallet/wallet/host_manager.dart';
import 'package:starcoin_wallet/wallet/node.dart';

void main() {
  Process process;
  Completer<void> processReadyCompleter;

  setUp(() async {
    Directory current = Directory.current;
    var command = join(current.path, 'starcoin/starcoin.exe');
    process = await Process.start(
        command,
        [
          "-n",
          "proxima",
        ],
        runInShell: true);
    processReadyCompleter = Completer<void>();

    process.stdout.transform(utf8.decoder).listen((data) {
      print('Process stdout: $data');

      // 检查输出中是否有表明进程已就绪的特定消息
      if (data.contains('Waiting Ctrl-C')) {
        processReadyCompleter.complete();
      }
    });

    // 等待进程就绪的信号或者超时
    await Future.any([
      processReadyCompleter.future,
      Future.delayed(Duration(seconds: 100))
    ]).catchError((_) => print('Process did not become ready in time.'));
  });

  test('node rpc test', () async {
    expect(processReadyCompleter.isCompleted, isTrue);

    final node = Node(SimpleHostManager(Set.from(["localhost"])));
    final account = await node.defaultAccount();
    expect(account.containsKey("address"), true);
  });

  tearDown(() async {
    if (process != null) {
      process.kill(ProcessSignal.sigquit);
      await process.exitCode;
    }
  });
}
