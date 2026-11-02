// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Advance Trainer';

  @override
  String get appSlogan => 'Tear through barriers, bearing tears on the ascent';

  @override
  String get newTask => 'New Task';

  @override
  String get emptyTitle => 'No training tasks yet';

  @override
  String get emptySubtitle =>
      'Create your first training item and push through, starting from Level 1';

  @override
  String get emptyCta => 'Create your first training task';

  @override
  String get statusDone => 'Done';

  @override
  String get statusActive => 'In progress';

  @override
  String get createTitle => 'New Training Task';

  @override
  String get fieldName => 'Training item name *';

  @override
  String get fieldGrade => 'Grade *';

  @override
  String get fieldBeginNum => 'Start number *';

  @override
  String get fieldPlus => 'Increment *';

  @override
  String get fieldBeginGrade => 'Start grade *';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get fieldFailRule => 'On failure';

  @override
  String get hintName => 'e.g. Bench press';

  @override
  String get errNameEmpty => 'Please enter a name';

  @override
  String get errNameExists => 'This name already exists';

  @override
  String get errInvalidParams =>
      'Enter valid numbers: grade≥1, start number/start grade≥0, increment≥1';

  @override
  String get submitCreate => 'Submit · Create task';

  @override
  String toastCreated(String name) {
    return 'Created \"$name\"';
  }

  @override
  String get unitReps => 'reps';

  @override
  String get unitPieces => 'pieces';

  @override
  String get unitKg => 'kg';

  @override
  String get failStay => 'Stay';

  @override
  String get failRecede => 'Recede';

  @override
  String get detailTitle => 'Task Detail';

  @override
  String get taskNotFound => 'Task not found';

  @override
  String unitLabel(String unit) {
    return 'Unit: $unit';
  }

  @override
  String seqCount(int count) {
    return 'Sequence · $count items';
  }

  @override
  String levelProgress(int done, int need) {
    return 'Level progress: $done / $need done';
  }

  @override
  String get confirmContinue => 'Continue';

  @override
  String get executeTitle => 'Execute Task';

  @override
  String get todayTarget => 'Complete this session';

  @override
  String checkedCount(int done, int total) {
    return 'Checked $done / $total';
  }

  @override
  String get confirmDone => 'Confirm & Complete';

  @override
  String get markFail => 'Mark incomplete';

  @override
  String itemIndex(int index) {
    return 'Item $index';
  }

  @override
  String get toastDoneFinish => 'All done — training complete';

  @override
  String get toastAdvance => 'Completed and advanced';

  @override
  String toastFail(String rule) {
    return 'Marked incomplete · $rule';
  }

  @override
  String gradePosEven(int n) {
    return 'Stage $n';
  }

  @override
  String gradePosOdd(int n) {
    return 'Stage $n';
  }

  @override
  String levelPos(int n) {
    return 'Level $n';
  }

  @override
  String repPos(int n) {
    return 'Rep $n';
  }
}
