import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialOverlay {
  static TutorialCoachMark? tutorialCoachMark;

  static void showTutorial(BuildContext context, List<TargetFocus> targets) {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.blueAccent.withOpacity(0.8),
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        print('Tutorial finished');
        return true; // Explicitly return a boolean value
      },
      onClickTarget: (target) {
        print('Target clicked: ${target.identify}');
      },
      onSkip: () {
        print('Tutorial skipped');
        return true; // Explicitly return a boolean value
      },
      onClickOverlay: (target) {
        print('Overlay clicked');
      },
    );

    tutorialCoachMark?.show(context: context);
  }
}
