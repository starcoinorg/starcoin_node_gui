//Locale资源类
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StarcoinLocalizations {
  StarcoinLocalizations(this.isZh);
  //是否为中文
  bool isZh = false;

  //为了使用方便，我们定义一个静态方法
  static StarcoinLocalizations of(BuildContext context) {
    return Localizations.of<StarcoinLocalizations>(
        context, StarcoinLocalizations);
  }

  String _t(String zh, String en) => isZh ? zh : en;

  String get title => _t("Starcoin 挖矿程序", "Starcoin Miner");
  String get slogan => _t("参与测试网挖矿 瓜分万U!", "Start Mining Win10K USDT/STC!");
  String get currentTask => _t("当前任务", "Current Task");
  String get progress => _t("进度", "Progress");
  String get balance => _t("当前余额", "Balance");
  String get minedBlocks => _t("已挖块数", "Mined");
  String get blockUnit => _t("块", "Blocks");
  String get currentDiff => _t("当前难度", "Current Difficulty");
  String get createNickyName => _t("创建昵称", "Create Nicky Name");
  String get confirm => _t("确认", "Confirm");
  String get generatePoster => _t("生成海报", "Share Poster");
  String get officialWebsite => _t("官网", "Official Website");
  String get privateKey => _t("保存私钥", "Save Private Key");
  String get nodeNotRun => _t("节点没有运行，请先启动节点", "Node is not running, please start node first.");
  String get fileNotFound => _t("Starcoin.exe 节点启动文件未找到，请重新配置节点文件,位置：", "Starcoin.exe file cannot found, Please check the file has exists!, Locate: ");
  String get alertTitle => _t("警告", "alert");

  // //Locale相关值，title为应用标题
  // String get title {
  //   return isZh ? "Starcoin 挖矿程序" : "Starcoin Miner";
  // }

  // String get slogon {
  //   return isZh ? "参与测试网挖矿 瓜分万U!" : "Start Mining Win10K USDT/STC!";
  // }

  // String get currentTask {
  //   return isZh ? "当前任务" : "Current Task";
  // }

  // String get progress {
  //   return isZh ? "进度" : "Progress";
  // }

  // String get balance {
  //   return isZh ? "当前余额" : "Balance";
  // }

  // String get minedBlocks {
  //   return isZh ? "已挖块数" : "Mined";
  // }

  // String get blockUnit {
  //   return isZh ? "块" : "Blocks";
  // }

  // String get currentDiff {
  //   return isZh ? "当前难度" : "Current Difficulty";
  // }

  // String get createNickyName {
  //   return isZh ? "创建昵称" : "Create Nicky Name";
  // }

  // String get confirm {
  //   return isZh ? "确认" : "Confirm";
  // }

  // String get generatePoster {
  //   return isZh ? "生成海报" : "Share Poster";
  // }

  // String get offcialWebSite {
  //   return isZh ? "官网" : "Offcial Website";
  // }

  // String get privateKey {
  //   return isZh ? "保存私钥" : "Save Private Key";
  // }

  // String get nodeNotRun {
  //   return isZh
  //       ? "节点没有运行，请先启动节点"
  //       : "Node is not running,please start node first.";
  // }
}

class StarcoinLocalizationsDelegate
    extends LocalizationsDelegate<StarcoinLocalizations> {
  const StarcoinLocalizationsDelegate();

  //是否支持某个Local
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  // Flutter会调用此类加载相应的Locale资源类
  @override
  Future<StarcoinLocalizations> load(Locale locale) {
    return SynchronousFuture<StarcoinLocalizations>(
        StarcoinLocalizations(locale.languageCode == "zh"));
  }

  @override
  bool shouldReload(StarcoinLocalizationsDelegate old) => false;
}
