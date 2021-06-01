import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:strokemonitor/widgets/monitor.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String value = "no";
  String _status = '';
  String _token = '';
  final databaseReference = FirebaseDatabase.instance.reference();
  void startServiceInPlatform() async {
    if (Platform.isAndroid) {
      var methodChannel = MethodChannel("com.example.strokemonitor");
      String data = await methodChannel.invokeMethod("startService");
      debugPrint(data);
    }
  }

  int position = DateTime.now().weekday.toInt();

  List<String> prevention = [
    "1. Lower blood pressure\n" +
        "High blood pressure is a huge factor, doubling or even quadrupling your stroke risk if it is not controlled. High blood pressure is the biggest contributor to the risk of stroke in both men and women. Monitoring blood pressure and, if it is elevated, treating it, is probably the biggest difference people can make to their vascular health.\n" +
        "Your ideal goal: Maintain a blood pressure of less than < 120/80 if possible. For some older people, this might not be possible because of medication side effects or dizziness with standing.\n" +
        "How to achieve it:\n" +
        "•\tReduce the salt in your diet, ideally to no more than 1,500 milligrams a day (about a half teaspoon).\n" +
        "•\tIncrease polyunsaturated and monounsaturated fats in your diet, while avoiding foods high in saturated fats.\n" +
        "•\tEat 4 to 5 cups of fruits and vegetables every day, one serving of fish two to three times a week, and several daily servings of whole grains and low-fat dairy.\n" +
        "•\tGet more exercise — at least 30 minutes of activity a day, and more, if possible.\n" +
        "•\tQuit smoking, if you smoke.\n" +
        "If needed, take blood pressure medicines.\n",
    "2. Lose weight\n" +
        "Obesity, as well as the complications linked to it (including high blood pressure and diabetes), raises your odds of having a stroke. If you're overweight, losing as little as 10 pounds can have a real impact on your stroke risk.\n" +
        "Your goal: While an ideal body mass index (BMI) is 25 or less, that may not be realistic for you. Work with your doctor to create a personal weight loss strategy.\n" +
        "How to achieve it:\n" +
        "•\tTry to eat no more than 1,500 to 2,000 calories a day (depending on your activity level and your current BMI).\n" +
        "•\tIncrease the amount of exercise you do with activities like walking, golfing, or playing tennis, and by making activity part of every single day.\n",
    "3. Exercise more\n" +
        "Exercise contributes to losing weight and lowering blood pressure, but it also stands on its own as an independent stroke reducer.\n" +
        "Your goal: Exercise at a moderate intensity at least five days a week.\n" +
        "How to achieve it:\n" +
        "•\tTake a walk around your neighborhood every morning after breakfast.\n" +
        "•\tStart a fitness club with friends.\n" +
        "•\tWhen you exercise, reach the level at which you're breathing hard, but you can still talk.\n" +
        "•\tTake the stairs instead of an elevator when you can.\n" +
        "•\tIf you don't have 30 consecutive minutes to exercise, break it up into 10- to 15-minute sessions a few times each day.\n",
    "4. If you drink — do it in moderation\n" +
        "Drinking a little alcohol is okay, and it may decrease your risk of stroke. Studies show that if you have about one drink per day, your risk may be lower. Once you start drinking more than two drinks per day, your risk goes up very sharply.\n" +
        "Your goal: Don't drink alcohol or do it in moderation.\n" +
        "How to achieve it:\n" +
        "•\tHave no more than one glass of alcohol a day.\n" +
        "•\tMake red wine your first choice, because it contains resveratrol, which is thought to protect the heart and brain.\n" +
        "•\tWatch your portion sizes. A standard-sized drink is a 5-ounce glass of wine, 12-ounce beer, or 1.5-ounce glass of hard liquor.\n",
    "5. Treat atrial fibrillation\n" +
        "Atrial fibrillation is a form of irregular heartbeat that causes clots to form in the heart. Those clots can then travel to the brain, producing a stroke. Atrial fibrillation carries almost a fivefold risk of stroke.\n" +
        "Your goal: If you have atrial fibrillation, get it treated.\n" +
        "How to achieve it:\n" +
        "•\tIf you have symptoms such as heart palpitations or shortness of breath, see your doctor for an exam.\n" +
        "•\tYou may need to take an anticoagulant drug (blood thinner) such as warfarin (Coumadin) or one of the newer direct-acting anticoagulant drugs to reduce your stroke risk from atrial fibrillation. Your doctors can guide you through this treatment.\n",
    "6. Treat diabetes\n" +
        "Having high blood sugar damages blood vessels over time, making clots more likely to form inside them.\n" +
        "Your goal: Keep your blood sugar under control.\n" +
        "How to achieve it:\n" +
        "•\tMonitor your blood sugar as directed by your doctor.\n" +
        "•\tUse diet, exercise, and medicines to keep your blood sugar within the recommended range.\n",
    "7. Quit smoking\n" +
        "Smoking accelerates clot formation in a couple of different ways. It thickens your blood, and it increases the amount of plaque buildup in the arteries. Along with a healthy diet and regular exercise, smoking cessation is one of the most powerful lifestyle changes that will help you reduce your stroke risk significantly.\n" +
        "Your goal: Quit smoking.\n" +
        "How to achieve it:\n" +
        "•\tAsk your doctor for advice on the most appropriate way for you to quit.\n" +
        "•\tUse quit-smoking aids, such as nicotine pills or patches, counseling, or medicine.\n" +
        "•\tDon't give up. Most smokers need several tries to quit. See each attempt as bringing you one step closer to successfully beating the habit.\n"
  ];

  @override
  Widget build(BuildContext context) {
    startServiceInPlatform();
    print(position);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /* Center(
            child: FloatingActionButton(
              key: Key('start'),
              child: Text("Start Background"),
              onPressed: () {
                startServiceInPlatform();
              },
            ),
          ),*/
          Monitor(),
          Center(
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
                    left: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
                    right: BorderSide(width: 1.0, color: Color(0xFFFF7F7F7F)),
                    bottom: BorderSide(width: 1.0, color: Color(0xFFFF7F7F7F)),
                  ),
                  color: Color.fromRGBO(250, 232, 230, 1.0),
                ),
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(20),
                child: Text(
                  prevention[position - 1],
                  key: Key('text'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
