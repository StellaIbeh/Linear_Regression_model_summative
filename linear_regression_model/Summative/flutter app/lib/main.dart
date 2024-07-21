import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insurance Cost Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PredictionForm(),
    );
  }
}

class PredictionForm extends StatefulWidget {
  @override
  _PredictionFormState createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();
  bool _isMale = true;
  bool _isSmoker = false;
  String _region = 'northwest';
  String _result = '';

  Future<void> _predict() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('https://insurance-prediction-9rpq.onrender.com/predict'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'age': int.parse(_ageController.text),
          'bmi': double.parse(_bmiController.text),
          'children': int.parse(_childrenController.text),
          'sex_male': _isMale ? 1 : 0,
          'sex_female': !_isMale ? 1 : 0,  // Include sex_female
          'smoker_yes': _isSmoker ? 1 : 0,
          'smoker_no': !_isSmoker ? 1 : 0,  // Include smoker_no
          'region_northwest': _region == 'northwest' ? 1 : 0,
          'region_southeast': _region == 'southeast' ? 1 : 0,
          'region_southwest': _region == 'southwest' ? 1 : 0,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _result = 'Predicted Cost: ${jsonDecode(response.body)['prediction']}';
        });
      } else {
        setState(() {
          _result = 'Error: ${response.reasonPhrase}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insurance Cost Prediction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bmiController,
                decoration: InputDecoration(labelText: 'BMI'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter BMI';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _childrenController,
                decoration: InputDecoration(labelText: 'Number of Children'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of children';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _isMale ? 'male' : 'female',
                decoration: InputDecoration(labelText: 'Sex'),
                items: [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _isMale = value == 'male';
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select sex';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _isSmoker ? 'yes' : 'no',
                decoration: InputDecoration(labelText: 'Smoker'),
                items: [
                  DropdownMenuItem(
                    value: 'yes',
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 'no',
                    child: Text('No'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _isSmoker = value == 'yes';
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select smoker status';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _region,
                decoration: InputDecoration(labelText: 'Region'),
                items: [
                  DropdownMenuItem(
                    value: 'northwest',
                    child: Text('Northwest'),
                  ),
                  DropdownMenuItem(
                    value: 'southeast',
                    child: Text('Southeast'),
                  ),
                  DropdownMenuItem(
                    value: 'southwest',
                    child: Text('Southwest'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _region = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select region';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _predict,
                child: Text('Predict'),
              ),
              SizedBox(height: 20),
              Text(
                _result,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

