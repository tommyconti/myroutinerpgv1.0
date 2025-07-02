import 'package:flutter/material.dart';
import 'task.dart';

class Routine {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Task> tasks;

  Routine({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tasks,
  });
} 