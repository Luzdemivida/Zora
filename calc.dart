import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';
  final List<String> _history = [];
  double _memory = 0.0;

  void _append(String value) {
    setState(() {
      _expression += value;
    });
  }

  void _clearAll() {
    setState(() {
      _expression = '';
      _result = '';
    });
  }

  void _backspace() {
    if (_expression.isEmpty) return;
    setState(() {
      _expression = _expression.substring(0, _expression.length - 1);
    });
  }

  void _saveToHistory(String expr, String res) {
    setState(() {
      _history.insert(0, '$expr = $res');
      if (_history.length > 50) _history.removeLast();
    });
  }

  void _memoryClear() {
    setState(() => _memory = 0.0);
  }

  void _memoryRecall() {
    setState(() {
      // insert memory value into the expression
      final mem = _memory.toString();
      _expression += mem;
    });
  }

  void _memoryAdd() {
    final val = _evaluateToDouble(silent: true);
    if (val != null) setState(() => _memory += val);
  }

  void _memorySubtract() {
    final val = _evaluateToDouble(silent: true);
    if (val != null) setState(() => _memory -= val);
  }

  double? _evaluateToDouble({bool silent = false}) {
    try {
      final res = _evaluateExpression(_expression);
      if (!silent) setState(() => _result = res);
      return double.tryParse(res);
    } catch (e) {
      if (!silent) setState(() => _result = 'Error');
      return null;
    }
  }

  String _evaluateExpression(String expr) {
    if (expr.trim().isEmpty) return '';

    // Preprocess: replace some common symbols and percent handling
    var e = expr.replaceAll('×', '*').replaceAll('÷', '/');
    e = e.replaceAll('%', '/100');
    e = e.replaceAll('^', '^'); // math_expressions uses pow for ^ via parsed operator

    // Replace unicode sqrt symbol if any
    e = e.replaceAll('√', 'sqrt');

    // Ensure functions are in correct form for Parser
    // map 'ln' to 'log' (math_expressions has 'ln' as natural log via 'ln')

    Parser p = Parser();
    ContextModel cm = ContextModel();

    // Handle 'exp' as e^x
    e = e.replaceAllMapped(RegExp(r'exp\(([^)]+)\)'), (m) => '(e^(${m[1]}))');

    // Replace occurrences of 'e' variable with math.e only when used as constant (careful)
    // We'll allow parser handle numbers; provide constant e in context
    cm.bindVariableName('e', Number(math.e));

    Expression parsed = p.parse(e);
    double eval = parsed.evaluate(EvaluationType.REAL, cm);
    final cleaned = eval.toString();
    _saveToHistory(expr, cleaned);
    return cleaned;
  }

  void _evaluate() {
    try {
      final res = _evaluateExpression(_expression);
      setState(() => _result = res);
    } catch (e) {
      setState(() => _result = 'Error');
    }
  }

  Widget _buildButton(String label,
      {Color? color, Color? textColor, double flex = 1, VoidCallback? onTap}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[200],
            foregroundColor: textColor ?? Colors.black,
            padding: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onTap ?? () => _append(label),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => _buildHistoryPanel(),
            ),
            tooltip: 'History',
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Column(
            children: [
              Expanded(
                flex: isWide ? 2 : 1,
                child: Container(
                  color: Colors.grey[100],
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(_expression, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(height: 8),
                      Text(_result, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    Row(children: [
                      _buildButton('MC', color: Colors.orange[100], onTap: _memoryClear),
                      _buildButton('MR', color: Colors.orange[100], onTap: _memoryRecall),
                      _buildButton('M+', color: Colors.orange[100], onTap: _memoryAdd),
                      _buildButton('M-', color: Colors.orange[100], onTap: _memorySubtract),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      _buildButton('(', color: Colors.blueGrey[50]),
                      _buildButton(')', color: Colors.blueGrey[50]),
                      _buildButton('%', color: Colors.blueGrey[50]),
                      _buildButton('÷', color: Colors.orange, textColor: Colors.white),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('×', color: Colors.orange, textColor: Colors.white),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('-', color: Colors.orange, textColor: Colors.white),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('+', color: Colors.orange, textColor: Colors.white),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      _buildButton('0', flex: 2),
                      _buildButton('.'),
                      _buildButton('=', color: Colors.green, textColor: Colors.white, onTap: _evaluate),
                    ]),
                    const SizedBox(height: 8),
                    // Scientific functions row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _buildButton('sin(', color: Colors.blue[50]),
                        _buildButton('cos(', color: Colors.blue[50]),
                        _buildButton('tan(', color: Colors.blue[50]),
                        _buildButton('ln(', color: Colors.blue[50]),
                        _buildButton('log(', color: Colors.blue[50]),
                        _buildButton('√(', color: Colors.blue[50], onTap: () => _append('sqrt(')),
                        _buildButton('^', color: Colors.blue[50]),
                        _buildButton('exp(', color: Colors.blue[50]),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      _buildButton('C', color: Colors.red[100], onTap: _clearAll),
                      _buildButton('⌫', color: Colors.red[100], onTap: _backspace),
                      _buildButton('Ans', color: Colors.grey[200], onTap: () => _append(_result)),
                      _buildButton('()', color: Colors.grey[200], onTap: () => _append('()')),
                    ])
                  ]),
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          if (_history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No history yet'),
            )
          else
            SizedBox(
              height: 300,
              child: ListView.separated(
                itemCount: _history.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final item = _history[idx];
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      // when tapped, put expression back into input (before the =)
                      final parts = item.split(' = ');
                      if (parts.isNotEmpty) {
                        setState(() {
                          _expression = parts[0];
                          _result = parts.length > 1 ? parts[1] : '';
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
              ),
            ),
          TextButton(
            onPressed: () => setState(() => _history.clear()),
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }
}
