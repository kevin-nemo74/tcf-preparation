import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/features/progress/study_plan_generator.dart';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  int _targetScore = 500;
  String _targetLevel = 'NCLC 7';
  int _weeklyCadence = 5;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 60));
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final uid = ProgressRepository.currentUid;
    if (uid == null) return;
    setState(() => _saving = true);
    final recent = await ProgressRepository.streamRecentAttempts(uid, limit: 20).first;
    final plan = StudyPlanGenerator.generate(
      targetScore: _targetScore,
      targetLevel: _targetLevel,
      targetDate: _targetDate,
      weeklyCadence: _weeklyCadence,
      recentAttempts: recent,
    );
    await ProgressRepository.saveStudyPlan(uid, plan);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Plan Setup')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.formMaxWidth(context)),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: Responsive.pagePadding(context, vertical: 16),
              children: [
            TextFormField(
              initialValue: '500',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target score (out of 699)'),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 300 || n > 699) return 'Choose a score between 300 and 699';
                return null;
              },
              onSaved: (v) => _targetScore = int.parse(v!.trim()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _targetLevel,
              items: const ['NCLC 4', 'NCLC 5', 'NCLC 6', 'NCLC 7', 'NCLC 8', 'NCLC 9', 'NCLC 10']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _targetLevel = v ?? 'NCLC 7'),
              decoration: const InputDecoration(labelText: 'Target level'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _weeklyCadence,
              items: const [3, 4, 5, 6, 7]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e sessions/week')))
                  .toList(),
              onChanged: (v) => setState(() => _weeklyCadence = v ?? 5),
              decoration: const InputDecoration(labelText: 'Weekly cadence'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Target date'),
              subtitle: Text('${_targetDate.year}-${_targetDate.month.toString().padLeft(2, '0')}-${_targetDate.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_month_rounded),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save plan'),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
