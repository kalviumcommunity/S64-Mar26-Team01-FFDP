import 'package:flutter/material.dart';
import '../utils/logger.dart';

/// A demo screen designed for testing Hot Reload, the Debug Console,
/// and Flutter DevTools features such as the Widget Inspector.
class DevToolsDemoScreen extends StatefulWidget {
  const DevToolsDemoScreen({Key? key}) : super(key: key);

  @override
  State<DevToolsDemoScreen> createState() => _DevToolsDemoScreenState();
}

class _DevToolsDemoScreenState extends State<DevToolsDemoScreen> {
  int _counter = 0;
  String _asyncResult = 'Tap the button to fetch data';

  @override
  void initState() {
    super.initState();
    AppLogger.infoLog('DevToolsDemoScreen initialized', tag: 'DEMO');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    AppLogger.debugLog('Counter incremented to $_counter', tag: 'DEMO');
  }

  Future<void> _simulateAsyncCall() async {
    AppLogger.infoLog('Starting async operation...', tag: 'DEMO');
    setState(() {
      _asyncResult = 'Loading...';
    });

    try {
      // Simulate a network delay for debugging async behaviour
      await Future.delayed(const Duration(seconds: 2));
      final result = 'Fetched at ${DateTime.now().toIso8601String()}';

      setState(() {
        _asyncResult = result;
      });
      AppLogger.debugLog('Async operation completed: $result', tag: 'DEMO');
    } catch (e, stack) {
      AppLogger.errorLog('Async operation failed', tag: 'DEMO', error: e, stackTrace: stack);
      setState(() {
        _asyncResult = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Try changing this color and pressing Hot Reload (Ctrl+S / Cmd+S)
    // to see the UI update instantly without losing counter state.
    const headerColor = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DevTools Demo'),
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hot Reload Counter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _incrementCounter,
                icon: const Icon(Icons.add),
                label: const Text('Increment'),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Async Debug Demo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _asyncResult,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _simulateAsyncCall,
                icon: const Icon(Icons.cloud_download),
                label: const Text('Simulate Fetch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
