// account_manager_page.dart
import 'package:flutter/material.dart';
import 'package:starcoin_node/pages/constant.dart';
import 'package:starcoin_wallet/wallet/host_manager.dart';
import 'package:starcoin_wallet/wallet/node.dart';

import 'localizations.dart';

class AccountManagerPage extends StatefulWidget {
  @override
  _AccountManagerPageState createState() => _AccountManagerPageState();
}

class _AccountManagerPageState extends State<AccountManagerPage> {
  List<String> accountList;

  _fetchAccounts() async {
    final node = Node(SimpleHostManager(Set.from([LOCALURL])));
    final result = await node.accountList();
    result.forEach((account) {
      final key = 'address';
      if (account.contains(key)) {
        accountList.add(account.get(key));
      }
    });
    print(result);
  }

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(StarcoinLocalizations.of(context).accountManage)),
      body: Container(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: 0,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(accountList[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // 在这里实现删除逻辑
                  // 由于 accountList 是 final 的，你可能需要将 AccountManagerPage 转换为 StatefulWidget
                  // 然后在 setState 中修改 accountList
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          btnAction_ShowAccountImportDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
btnAction_ShowAccountImportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController _textFieldController = TextEditingController();

      return AlertDialog(
        contentPadding: EdgeInsets.only(left: 20, top: 20, right: 20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _textFieldController,
                decoration: InputDecoration(
                    hintText:
                        StarcoinLocalizations.of(context).inputPrivateKeyHint),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(StarcoinLocalizations.of(context).confirm),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(StarcoinLocalizations.of(context).cancel),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

btnAction_RemoveConfirmDialog(BuildContext context, String address) async {}
