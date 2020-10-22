import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/models/license.dart';
import 'package:honeytoon/providers/version_provider.dart';
import 'package:honeytoon/screens/settings/setting_terms_of_service.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import './setting_privacy_screen.dart';
import './setting_section.dart';
import './setting_list.dart';
import './setting_tile.dart';
import './setting_myinfo_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SettingList(
          sections: [
            SettingsSection(
              title: '내 정보',
              tiles: [
                SettingsTile(title: '프로필 설정', onTap: (){Navigator.of(context).pushNamed(SettingMyinfoScreen.routeName);}),
              ]
            ),
            // SettingsSection(
            //   title: '알림',
            //   tiles: [
            //     SettingsTile(title: '푸시 알림',),
            //   ]
            // ),
            SettingsSection(
              title: '앱 정보',
              tiles: [
                SettingsTile(title: '버전 정보', subtitle: '1.0.0', onTap: () {_versionCheck(context); },),
                //SettingsTile(title: '공지사항',),
                //SettingsTile(title: '자주 묻는 질문',),
                SettingsTile(title: '이용약관', onTap: (){Navigator.of(context).pushNamed(SettingTermsScreen.routeName);}),
                SettingsTile(title: '개인정보취급방침', onTap: (){Navigator.of(context).pushNamed(SettingPrivacyScreen.routeName);},),
                SettingsTile(title: '오픈소스 라이선스', onTap: (){License.showLicensePage(context: context);}),
              ],
            ),
          ]
    );
  }

  void _versionCheck(BuildContext ctx) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    String newVersionStr = await Provider.of<VersionProvider>(context, listen: false).getNewestVersion();
    double newVersion = double.parse(newVersionStr.replaceAll(".", ""));
    double appVersion = double.parse(info.version.replaceAll(".", ""));
    
    if(appVersion < newVersion){
      _showUpdateVersionDialog(ctx);
    } else {
      _showNewestVersionDialog(ctx);
    }

  }

  void _showNewestVersionDialog(ctx) async {
    await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return Platform.isIOS 
        ? new CupertinoAlertDialog(
          title: Text('업데이트'),
          content: Text('최신 버전입니다'),
          actions: [
            FlatButton(onPressed: (){Navigator.pop(context);}, child: Text('확인'))
          ],
        )
        : new AlertDialog(
          title: Text('업데이트'),
          content: Text('최신 버전입니다'),
          actions: [
            FlatButton(onPressed: (){Navigator.pop(context);}, child: Text('확인'))
          ],
        );
      }
    );
  }
  void _showUpdateVersionDialog(ctx) async {
    await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        String title = '허니툰 버전 업그레이드';
        String message = '지금 바로 업데이트 가능합니다.';

        return Platform.isIOS 
        ? new CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text('업데이트'),
              onPressed: () => _launchAppStore
            ),
            FlatButton(onPressed:() => Navigator.pop(context), child: Text('나중에'))
          ]
        )
        : new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text('업데이트'),
              onPressed: () => _launchAppStore
            ),
            FlatButton(onPressed:() => Navigator.pop(context), child: Text('나중에'))
          ]
        );
      }
    );
  }

  void _launchAppStore(){
    LaunchReview.launch(androidAppId: "com.jeonghyun.honeytoon", iOSAppId: "1534527213");
  }

  
}