import 'package:flutter/material.dart';
import '../models/task.dart';
import '../resources/strings.dart';
import '../resources/colors.dart';
import '../resources/dimens.dart';

// Schermata per creare o modificare una quest.
class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  TimeOfDay? _selectedTime;
  
  TaskDifficulty _difficulty = TaskDifficulty.easy;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _categoryController.text = widget.task!.category;
      if (widget.task!.time.isNotEmpty) {
        final timeParts = widget.task!.time.split(':');
        _selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      }
      _difficulty = widget.task!.difficulty;
      _selectedDate = widget.task!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? AppStrings.questTitle : AppStrings.editQuest),
        backgroundColor: AppColors.purple800,
        foregroundColor: AppColors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.purple900, AppColors.indigo900],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - AppDimens.screenPadding * 2),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: AppDimens.verticalSpacingMedium),
                        _buildTextField(_titleController, AppStrings.questTitle, Icons.flag, maxLength: 30),
                        const SizedBox(height: AppDimens.verticalSpacingMedium),
                        _buildTextField(_descriptionController, AppStrings.description, Icons.description, maxLines: 3, maxLength: 100),
                        const SizedBox(height: AppDimens.verticalSpacingMedium),
                        _buildTextField(_categoryController, AppStrings.category, Icons.category, maxLength: 20),
                        const SizedBox(height: AppDimens.verticalSpacingMedium),
                        _buildTimeSelector(),
                        const SizedBox(height: AppDimens.verticalSpacingMedium),
                        _buildDifficultySelector(),
                        const SizedBox(height: AppDimens.verticalSpacingMedium),
                        _buildDateSelector(),
                        const SizedBox(height: AppDimens.verticalSpacingLarge),
                        const Spacer(),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Campo di testo personalizzato.
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.white70),
        prefixIcon: Icon(icon, color: AppColors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.white, width: 2),
        ),
      ),
    );
  }

  // Selettore orario.
  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white10,
          borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
          border: Border.all(color: AppColors.white30),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.white),
            const SizedBox(width: AppDimens.horizontalItemSpacing),
            Text(
              _selectedTime == null ? AppStrings.selectTime : _selectedTime!.format(context),
              style: const TextStyle(color: AppColors.white, fontSize: AppDimens.bodyFontSize),
            ),
          ],
        ),
      ),
    );
  }

  // Selettore difficoltà.
  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
        border: Border.all(color: AppColors.white30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: AppColors.white),
              SizedBox(width: AppDimens.buttonSpacing),
              Text(AppStrings.difficulty, style: TextStyle(color: AppColors.white, fontSize: AppDimens.bodyFontSize)),
            ],
          ),
          const SizedBox(height: AppDimens.verticalItemSpacing),
          Row(
            children: [
              _buildDifficultyChip('easy', AppStrings.easy, AppColors.green),
              const SizedBox(width: AppDimens.buttonSpacing),
              _buildDifficultyChip('medium', AppStrings.medium, AppColors.orange),
              const SizedBox(width: AppDimens.buttonSpacing),
              _buildDifficultyChip('hard', AppStrings.hard, AppColors.red),
            ],
          ),
        ],
      ),
    );
  }

  // Chip per la difficoltà.
  Widget _buildDifficultyChip(String value, String label, Color color) {
    final difficultyValue = TaskDifficulty.values.firstWhere((e) => e.name == value);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _difficulty = difficultyValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.chipSpacing),
          decoration: BoxDecoration(
            color: _difficulty == difficultyValue ? color : AppColors.white10,
            borderRadius: BorderRadius.circular(AppDimens.chipBorderRadius),
            border: Border.all(
              color: _difficulty == difficultyValue ? color : AppColors.white30,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _difficulty == difficultyValue ? AppColors.white : AppColors.white70,
              fontWeight: _difficulty == difficultyValue ? FontWeight.bold : FontWeight.normal,
              fontSize: AppDimens.bodyFontSize,
            ),
          ),
        ),
      ),
    );
  }

  // Selettore data.
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white10,
          borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
          border: Border.all(color: AppColors.white30),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.white),
            const SizedBox(width: AppDimens.horizontalItemSpacing),
            Text(
              '${AppStrings.date}: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(color: AppColors.white, fontSize: AppDimens.bodyFontSize),
            ),
          ],
        ),
      ),
    );
  }

  // Pulsante per salvare la quest.
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white10,
          foregroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.white30),
          padding: const EdgeInsets.symmetric(vertical: AppDimens.formFieldSpacing),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardBorderRadiusSmall)),
        ),
        child: Text(
          widget.task == null ? AppStrings.createQuest : AppStrings.save,
          style: const TextStyle(fontSize: AppDimens.subtitleFontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Salva la quest (crea o aggiorna).
  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.insertTitle)),
      );
      return;
    }

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      category: _categoryController.text,
      difficulty: _difficulty,
      time: _selectedTime == null ? '' : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      date: _selectedDate,
      completed: widget.task?.completed ?? false,
    );

    Navigator.pop(context, task);
  }
}