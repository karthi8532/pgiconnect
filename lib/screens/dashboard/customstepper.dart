import 'package:flutter/material.dart';

class CustomHorizontalStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Function(int) onStepTapped;

  const CustomHorizontalStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return InkWell(
            onTap: () => onStepTapped(index),
            child: Row(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? Colors.blue
                              : Colors.grey,
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent ? Colors.blue : Colors.black,
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 30,
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
