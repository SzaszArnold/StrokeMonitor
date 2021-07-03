import 'package:flutter/material.dart';
import 'package:strokemonitor/screens/charts_screen.dart';
import 'package:strokemonitor/screens/home_screen.dart';
import 'package:strokemonitor/widgets/main_drawer.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;
  @override
  void initState() {
    _pages = [
      {
        'page': HomeScreen(),
        'title': 'Home',
      },
      {
        'page': ChartsScreen(),
        'title': 'Charts',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

/*Based on the documentation at the link: https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
                                          https://api.flutter.dev/flutter/material/showDialog.html
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedPageIndex]['title']),
        actions: [
          if (_pages[_selectedPageIndex]['title'] == 'Charts')
            IconButton(
              icon: const Icon(Icons.help),
              tooltip: 'Information',
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Text('How to use the chart'),
                          content: Text('Select a filter:\n' +
                              "Day: Will return your heart rate in every hour \n" +
                              "Week: Will return your resting heart rate in last seven day\n" +
                              "Hour: Press the Day button, select a number and press the hour glass button and will return your heart rate in the selected hour"),
                        ));
              },
            ),
        ],
      ),
      drawer: MainDrawer(),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.bar_chart),
            label: 'Charts',
          ),
        ],
      ),
    );
  }
}
