import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/local_tests_data.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';

import 'question_screen.dart';

class TestListScreen extends StatefulWidget {
  const TestListScreen({super.key});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  late Future<List<TestModel>> testsFuture;

  @override
  void initState() {
    super.initState();
    testsFuture = LocalTestsData.loadTests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compréhension Écrite"),
      ),
      body: FutureBuilder<List<TestModel>>(
        future: testsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No tests available"),
            );
          }

          final tests = snapshot.data!;

          return ListView.builder(
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    test.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "${test.questions.length} questions • ${test.durationMinutes} min"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            QuestionScreen(test: test),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
