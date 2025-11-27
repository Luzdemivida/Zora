import 'package:flutter/material.dart';

/// Restored original BMI calculator
class BMIScreen extends StatefulWidget {
  const BMIScreen({Key? key}) : super(key: key);

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dietController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String bmiText = '';
  String category = '';
  String recommendations = '';

  void calculate() {
    final h = double.tryParse(heightController.text);
    final w = double.tryParse(weightController.text);
    if (h == null || h <= 0 || w == null || w <= 0) {
      setState(() {
        bmiText = '';
        category = '';
        recommendations = 'Please enter valid height and weight.';
      });
      return;
    }

    final bmi = w / (h * h);
    String cat;
    String recs;

    if (bmi < 18.5) {
      cat = 'Underweight';
      recs = 'Consider a nutrient-dense diet and strength training.';
    } else if (bmi < 25) {
      cat = 'Normal weight';
      recs = 'Great — maintain balanced diet and regular activity.';
    } else if (bmi < 30) {
      cat = 'Overweight';
      recs = 'Aim for gradual weight loss with diet and exercise.';
    } else {
      cat = 'Obese';
      recs = 'Consult a healthcare professional for a plan.';
    }

    setState(() {
      bmiText = bmi.toStringAsFixed(1);
      category = cat;
      recommendations = recs;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    dietController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text('Name', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: _dec('Full name')),
              const SizedBox(height: 12),

              const Text('Age', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              TextField(controller: ageController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _dec('Age')),
              const SizedBox(height: 12),

              const Text('Diet (brief)', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              TextField(controller: dietController, style: const TextStyle(color: Colors.white), decoration: _dec('e.g., Vegetarian')),
              const SizedBox(height: 12),

              const Text('Height (meters)', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              TextField(controller: heightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: _dec('e.g., 1.75')),
              const SizedBox(height: 12),

              const Text('Weight (kg)', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              TextField(controller: weightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: _dec('e.g., 70')),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: calculate,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Calculate BMI', style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 20),

              if (bmiText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('BMI: $bmiText', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Category: $category', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('Recommendations:', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(recommendations, style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
