import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StrokeRisk extends StatefulWidget {
  @override
  _StrokeRiskState createState() => _StrokeRiskState();
}

/*Based on the documentation at the link: https://flutter.dev/docs/development/ui/widgets/material
                                          https://firebase.flutter.dev/docs/firestore/usage
                                          https://firebase.flutter.dev/docs/auth/usage/
                                          https://pub.dev/packages/image_picker
*/
class _StrokeRiskState extends State<StrokeRisk> {
  final _auth = FirebaseAuth.instance;
  Map<int, String> mappedAge = {0: "<65", 1: "65-75", 2: ">75"};
  Map<int, String> mappedGender = {0: "Male", 1: "Female"};
  bool valueCheckBox1 = false;
  bool valueCheckBox2 = false;
  bool valueCheckBox3 = false;
  bool valueCheckBox4 = false;
  bool valueCheckBox5 = false;
  int ageScore = 0;
  int genderScore = 0;
  int riskScore = 0;
  /* Scores, and questions based at link: https://www.msdmanuals.com/professional/cardiovascular-disorders/arrhythmias-and-conduction-disorders/atrial-fibrillation*/
  void _trySubmit() async {
    var totalScore = 0;
    totalScore = ageScore + genderScore + riskScore;
    var str = "0% per year.";
    if (totalScore == 0) str = "1.9% per year.";
    if (totalScore == 1) str = "2.8% per year.";
    if (totalScore == 2) str = "4% per year.";
    if (totalScore == 3) str = "5.9% per year.";
    if (totalScore == 4) str = "8.5% per year.";
    if (totalScore == 5) str = "12.5% per year.";
    if (totalScore == 6) str = "18.2% per year.";
    FirebaseFirestore.instance
        .collection('risk')
        .doc(_auth.currentUser.email
            .substring(0, _auth.currentUser.email.lastIndexOf('@')))
        .set({'score': totalScore, 'percentage': str});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Clinical Features",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 12),
                  CheckboxListTile(
                    title: Text('Congestive heart failure / LV dysfunction'),
                    checkColor: Colors.greenAccent,
                    activeColor: Theme.of(context).primaryColor,
                    value: this.valueCheckBox1,
                    onChanged: (bool value) {
                      setState(() {
                        this.valueCheckBox1 = value;
                        print(value);
                        if (value == true) {
                          riskScore += 1;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('History of stroke, TIA or thromboembolism'),
                    checkColor: Colors.greenAccent,
                    activeColor: Theme.of(context).primaryColor,
                    value: this.valueCheckBox2,
                    onChanged: (bool value) {
                      setState(() {
                        this.valueCheckBox2 = value;
                        print(value);
                        if (value == true) {
                          riskScore += 2;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Hypertension'),
                    checkColor: Colors.greenAccent,
                    activeColor: Theme.of(context).primaryColor,
                    value: this.valueCheckBox3,
                    onChanged: (bool value) {
                      setState(() {
                        this.valueCheckBox3 = value;
                        print(value);
                        if (value == true) {
                          riskScore += 1;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Diabetes Mellitus'),
                    checkColor: Colors.greenAccent,
                    activeColor: Theme.of(context).primaryColor,
                    value: this.valueCheckBox4,
                    onChanged: (bool value) {
                      setState(() {
                        this.valueCheckBox4 = value;
                        print(value);
                        if (value == true) {
                          riskScore += 1;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Vascular disese (history of MI, PVD)'),
                    checkColor: Colors.greenAccent,
                    activeColor: Theme.of(context).primaryColor,
                    value: this.valueCheckBox5,
                    onChanged: (bool value) {
                      setState(() {
                        this.valueCheckBox5 = value;
                        print(value);
                        if (value == true) {
                          riskScore += 1;
                        }
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (_, StateSetter setState) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Gender : ',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        ...mappedGender.entries.map(
                          (MapEntry<int, String> mapEntry) => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio(
                                activeColor: Theme.of(context).primaryColor,
                                groupValue: riskScore,
                                value: mapEntry.key,
                                onChanged: (value) => setState(
                                  () {
                                    riskScore = value;
                                    print("$value");
                                    genderScore += value;
                                  },
                                ),
                              ),
                              Text(mapEntry.value)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (_, StateSetter setState) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Age : ',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        ...mappedAge.entries.map(
                          (MapEntry<int, String> mapEntry) => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio(
                                activeColor: Theme.of(context).primaryColor,
                                groupValue: riskScore,
                                value: mapEntry.key,
                                onChanged: (value) => setState(
                                  () {
                                    riskScore = value;
                                    print("$value");
                                    ageScore += value;
                                  },
                                ),
                              ),
                              Text(mapEntry.value)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                    ),
                    child: Text('Submit'),
                    onPressed: () {
                      _trySubmit();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
