import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Stroke Monitor', () {
    // First, define the Finders and use them to locate widgets from the test suite

    final buttonFinder = find.byValueKey('button');
    final email = find.byValueKey('email');
    final password = find.byValueKey('password');
    final drawerFinder = find.byTooltip('Open navigation menu');
    final userText = find.byValueKey('userText');
    final navTitle = find.byValueKey('navContact person');
    final contactName = find.byValueKey('contactName');
    final contactPhone = find.byValueKey('contactPhone');
    final contactNameField = find.byValueKey('name');
    final contactPhoneField = find.byValueKey('phone');
    final saveContact = find.byValueKey('saveContact');
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('UI test', () async {
      await driver.tap(email);
      await driver.enterText("arnoldszasz06@gmail.com");
      await driver.tap(password);
      await driver.enterText("12345678");
      await driver.tap(buttonFinder);
      await driver.waitFor(drawerFinder);
      final timeline = await driver.traceAction(() async {
        await driver.tap(drawerFinder);
        print('clicked on drawer');
        expect(await driver.getText(userText), "Hi arnoldszasz06");
      });
      print('${await driver.getText(userText)}');
      await driver.tap(navTitle);
      print('${await driver.getText(contactName)}');
      await driver.tap(contactNameField);
      await driver.enterText("Arni");
      await driver.tap(contactPhoneField);
      await driver.enterText("1234567891");
      await driver.tap(saveContact);
      print('${await driver.getText(contactName)}');
      print('${await driver.getText(contactPhone)}');
      expect(await driver.getText(contactName), "Arni");
      expect(await driver.getText(contactPhone), "1234567891");

      final summary = new TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile('drawer_summary', pretty: true);
      await summary.writeTimelineToFile('drawer_timeline', pretty: true);
    });
  });
}
