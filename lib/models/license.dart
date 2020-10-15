import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class License extends LicenseEntry{
  final packages;
  final paragraphs;

  License(this.packages, this.paragraphs);


static void showLicensePage ({
    @required BuildContext context,
    String applicationName,
    String applicationVersion,
    Widget applicationIcon,
    String applicationLegalese,
    bool useRootNavigator = false,
  }) {
    addLicense();
    Navigator.of(context, rootNavigator: useRootNavigator).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => LicensePage(
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
      ),
  ));
  }

}

Stream<LicenseEntry> licenses() {
  return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
    //const LicenseEntryWithLineBreaks(<String>['pirate package'], 'pirate license')
  ]);
}

void addLicense(){
  LicenseRegistry.addLicense(licenses);
}

