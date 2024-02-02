// account_manager_page.dart

import 'package:flutter/material.dart';
import 'package:starcoin_node/pages/constant.dart';
import 'package:starcoin_node/pages/popups.dart';
import 'package:starcoin_wallet/wallet/host_manager.dart';
import 'package:starcoin_wallet/wallet/node.dart';

import 'localizations.dart';

// ignore: must_be_immutable
class AccountManagerPage extends StatefulWidget {
  String defaultAccount;

  AccountManagerPage({Key key, this.defaultAccount}) : super(key: key);

  @override
  _AccountManagerPageState createState() => _AccountManagerPageState();
}

class _AccountManagerPageState extends State<AccountManagerPage> {
  List<String> _accountList = [];

  _fetchAccounts() async {
    _accountList = [];
    final node = Node(SimpleHostManager(Set.from([LOCALURL])));
    final result = await node.accountList();

    setState(() {
      result.forEach((account) {
        final key = 'address';
        if (account.containsKey(key)) {
          _accountList.add(account[key]);
        }
      });
    });
  }

  _importAccount(
      String accountAddress, String privateKey, String password) async {
    final node = Node(SimpleHostManager(Set.from([LOCALURL])));
    final result =
        await node.importAccount(accountAddress, privateKey, password);

    await _fetchAccounts();
  }

  _setAccountDefault(String accountAddress) async {
    final node = Node(SimpleHostManager(Set.from([LOCALURL])));
    await node.setDefaultAccount(accountAddress);

    widget.defaultAccount = accountAddress; 
    await _fetchAccounts();
  }

  _removeAccount(String accountAddress, String password) async {
    final node = Node(SimpleHostManager(Set.from([LOCALURL])));
    await node.removeAccount(accountAddress, password);

    await _fetchAccounts();
  }

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  bool isDefaultAccount(String account) {
    return widget.defaultAccount == account;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(StarcoinLocalizations.of(context).accountManage)),
      body: Container(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: _accountList.length,
          itemBuilder: (BuildContext context, int index) {
            String account = _accountList[index];
            return ListTile(
              title: Text(account),
              leading: Checkbox(
                value: isDefaultAccount(account),
                onChanged: isDefaultAccount(account)
                    ? (bool value) {
                        return true;
                      }
                    : (bool value) {
                        if (value) {
                          btnAction_SetDefaultConfirmDialog(context, account,
                              (String confirmedAccountAddress) {
                            try {
                              _setAccountDefault(confirmedAccountAddress);
                            } catch (e) {
                              showSnackBar(context, e.toString());
                            }
                          });
                        }
                      },
              ),
              trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: isDefaultAccount(account)
                      ? null
                      : () {
                          btnAction_RemoveConfirmDialog(context, account,
                              (String accountAddress) {
                            try {
                              _removeAccount(accountAddress, null);
                            } catch (e) {
                              showSnackBar(context, e.toString());
                            }
                          });
                        }),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          btnAction_ShowAccountImportDialog(context,
              (String accountAddress, String privateKey) async {
            try {
              _importAccount(accountAddress, privateKey, "");
            } catch (e) {
              showSnackBar(context, e.toString());
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

typedef OnConfirmCallback = void Function(String value);
typedef OnImportAccountConfirmCallback = void Function(
    String accountAddress, String privateKey);

// ignore: non_constant_identifier_names
btnAction_ShowAccountImportDialog(
    BuildContext context, OnImportAccountConfirmCallback confirmCallback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController _accountAddressFieldController =
          TextEditingController();
      TextEditingController _privateKeyFieldController =
          TextEditingController();

      return AlertDialog(
        contentPadding: EdgeInsets.only(left: 20, top: 20, right: 20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(StarcoinLocalizations.of(context)
                      .importAccountPage_AccountAddress_Label),
                  Padding(padding: EdgeInsets.all(4.0)),
                  Expanded(
                      child: TextField(
                    controller: _accountAddressFieldController,
                    decoration: InputDecoration(
                        hintText: StarcoinLocalizations.of(context)
                            .importAccountPage_inputAccountAddressHint),
                  )),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(StarcoinLocalizations.of(context)
                      .importAccountPage_PrivateKey_Label),
                  Padding(padding: EdgeInsets.all(4.0)),
                  Expanded(
                      child: TextField(
                    controller: _privateKeyFieldController,
                    decoration: InputDecoration(
                        hintText: StarcoinLocalizations.of(context)
                            .importAccountPage_inputPrivateKeyHint),
                  )),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      confirmCallback(_accountAddressFieldController.text,
                          _privateKeyFieldController.text);
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
              SizedBox(height: 5)
            ],
          ),
        ),
      );
    },
  );
}

btnAction_RemoveConfirmDialog(
    BuildContext context, String address, OnConfirmCallback callback) async {}

btnAction_SetDefaultConfirmDialog(
    BuildContext context, String address, OnConfirmCallback callback) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(StarcoinLocalizations.of(context).alertTitle),
        content: Text(StarcoinLocalizations.of(context)
            .accountManager_SetDefaultQuery
            .replaceFirst("%address%", address)), // 对话框的主要内容
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
            },
            child: Text(StarcoinLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              callback(address);
              Navigator.of(context).pop();
            },
            child: Text(StarcoinLocalizations.of(context).confirm),
          ),
        ],
      );
    },
  );
}
