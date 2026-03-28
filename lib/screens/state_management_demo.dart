import 'package:flutter/material.dart';

class StateManagementDemo extends StatefulWidget {
  @override
  _StateManagementDemoState createState() => _StateManagementDemoState();
}

class _StateManagementDemoState extends State<StateManagementDemo> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('State Management Demo'),
        backgroundColor: _counter >= 5 ? Colors.green : Colors.blue,
      ),
      body: Container(
        color: _counter >= 10 ? Colors.amber[100] : Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Button pressed:',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '$_counter times',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _counter >= 10 ? Colors.red : Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _counter >= 10 ? '🎉 Milestone reached!' : 'Keep going!',
                style: TextStyle(
                  fontSize: 16,
                  color: _counter >= 10 ? Colors.green : Colors.grey,
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _incrementCounter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Increment'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _decrementCounter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Decrement'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _resetCounter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_counter > 0)
                Text(
                  'Last action: ${DateTime.now().toString().split('.')[0]}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}