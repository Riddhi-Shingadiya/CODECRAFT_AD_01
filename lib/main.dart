import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const Color colorGrey = Color(0xFFA5A5A5);
  static const Color colorDarkGrey = Color(0xFF333333);
  static const Color colorOrange = Color(0xFFFF9F0A);

  List<String> _history = [];
  String _equation = "0"; // What is being typed
  String _result = "0"; // The calculated answer
  bool isOperator(String s) => ["+", "-", "×", "÷"].contains(s);

  void _onButtonPressed(String label) {
    setState(() {
      if (label == "AC") {
        _equation = "0";
        _result = "0";
      } else if (label == "BACKSPACE") {
        if (_equation.length > 1) {
          _equation = _equation.substring(0, _equation.length - 1);
        } else {
          _equation = "0";
        }
        _autoCalculate();
      } else if (label == "=") {
        _history.add(
          "${DateTime.now().toIso8601String()}|$_equation = $_result",
        );
        _equation = _result;
      } else {
        if (_equation == "0") {
          _equation = label;
        } else {
          _equation += label;
        }
        _autoCalculate();
      }
    });
  }

  void _autoCalculate() {
    try {
      String expression = _equation.replaceAll('×', '*').replaceAll('÷', '/');

      if (expression.endsWith('+') ||
          expression.endsWith('-') ||
          expression.endsWith('*') ||
          expression.endsWith('/')) {
        expression = expression.substring(0, expression.length - 1);
      }

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      _result = eval.toString().replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
    } catch (e) {}
  }

  Widget buildButton(
    String label,
    Color backgroundColor,
    Color textColor,
    double fontSize, {
    bool isIcon = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: AspectRatio(
          aspectRatio: 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              elevation: 0,
              shape: const CircleBorder(),
            ),
            onPressed: () => _onButtonPressed(isIcon ? "BACKSPACE" : label),
            child: isIcon
                ? Icon(Icons.backspace_outlined, size: fontSize)
                : Text(label, style: TextStyle(fontSize: fontSize)),
          ),
        ),
      ),
    );
  }

  double get buttonHeight => MediaQuery.of(context).size.width / 4 - 12;

  Widget buildZeroButton() {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.all(6),
        height: buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorDarkGrey,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const StadiumBorder(),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 30),
          ),
          onPressed: () => _onButtonPressed("0"),
          child: const Text('0', style: TextStyle(fontSize: 32)),
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        Map<String, List<String>> grouped = {};

        for (var item in _history) {
          final split = item.split("|");
          final time = DateTime.parse(split[0]);
          final data = split[1];

          String label;

          final now = DateTime.now();
          final diff = now.difference(time).inDays;

          if (diff == 0) {
            label = "Today";
          } else if (diff == 1) {
            label = "Yesterday";
          } else {
            label = "$diff days ago";
          }

          grouped.putIfAbsent(label, () => []).add(data);
        }

        if (_history.isEmpty) {
          return const Center(
            child: Text(
              "No History",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDE LABEL (Today / Yesterday)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // HISTORY ITEMS
                ...entry.value.map((item) {
                  final parts = item.split("=");

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Expression (RIGHT)
                        Text(
                          parts[0].trim(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 36,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Result (RIGHT, below)
                        Text(
                          parts[1].trim(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Divider(color: Colors.white10),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () {
            _showHistory();
          },
        ),
        title: const Text("Calculator"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _equation,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      style: const TextStyle(fontSize: 70, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            // your keypad remains same...
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      buildButton("AC", colorGrey, Colors.black, 22),
                      buildButton(
                        "",
                        colorGrey,
                        Colors.black,
                        28,
                        isIcon: true,
                      ),
                      buildButton("%", colorGrey, Colors.black, 28),
                      buildButton("÷", colorOrange, Colors.white, 36),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("7", colorDarkGrey, Colors.white, 32),
                      buildButton("8", colorDarkGrey, Colors.white, 32),
                      buildButton("9", colorDarkGrey, Colors.white, 32),
                      buildButton("×", colorOrange, Colors.white, 36),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("4", colorDarkGrey, Colors.white, 32),
                      buildButton("5", colorDarkGrey, Colors.white, 32),
                      buildButton("6", colorDarkGrey, Colors.white, 32),
                      buildButton("-", colorOrange, Colors.white, 36),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton("1", colorDarkGrey, Colors.white, 32),
                      buildButton("2", colorDarkGrey, Colors.white, 32),
                      buildButton("3", colorDarkGrey, Colors.white, 32),
                      buildButton("+", colorOrange, Colors.white, 36),
                    ],
                  ),
                  Row(
                    children: [
                      buildZeroButton(),
                      buildButton(".", colorDarkGrey, Colors.white, 32),
                      buildButton("=", colorOrange, Colors.white, 36),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
