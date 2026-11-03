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
  String get appSlogan => 'Tear through barriers, strive upward';

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
  String get statusWait => 'Not started';

  @override
  String get createTitle => 'New Task';

  @override
  String get editTitle => 'Edit Task';

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
  String get fieldMethod => 'Task type';

  @override
  String get fieldGoal => 'Specific goal';

  @override
  String get fieldFailRule => 'On failure';

  @override
  String get hintName => 'e.g. Bench press';

  @override
  String get hintGoal => 'e.g. 50 push-ups daily, 1 min rest between sets';

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
  String get submitEdit => 'Submit · Save task';

  @override
  String toastCreated(String name) {
    return 'Created \"$name\"';
  }

  @override
  String toastSaved(String name) {
    return 'Saved \"$name\"';
  }

  @override
  String get methodSport => 'Sport';

  @override
  String get methodStudy => 'Study';

  @override
  String get methodTask => 'Task';

  @override
  String get methodOther => 'Other';

  @override
  String get failStay => 'Stay';

  @override
  String get failRecede => 'Recede';

  @override
  String achievedText(String grade, String level) {
    return 'Completed $grade · $level';
  }

  @override
  String get detailTitle => 'Task Detail';

  @override
  String get taskNotFound => 'Task not found';

  @override
  String get pendingExec => 'To execute';

  @override
  String methodLabel(String method) {
    return 'Task type: $method';
  }

  @override
  String goalHint(String goal) {
    return 'Specific goal: $goal';
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
  String get refLabel => 'Ref';

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

  @override
  String get manageTitle => 'Manage Task';

  @override
  String get manageEdit => 'Edit Task';

  @override
  String get manageDelete => 'Delete Task';

  @override
  String get manageLogs => 'View Records';

  @override
  String get deleteTitle => 'Delete this task?';

  @override
  String get deleteWarn =>
      'This cannot be undone. The task\'s progress and all its completion records will be deleted.';

  @override
  String get deleteCancel => 'Cancel';

  @override
  String get deleteConfirm => 'Delete';

  @override
  String toastDeleted(String name) {
    return 'Deleted \"$name\" and all its records';
  }

  @override
  String get logsTitle => 'Records';

  @override
  String get logsEmpty => 'No completed records yet';

  @override
  String get logsEmptyHint =>
      'After finishing a session, the time and position will be recorded here';

  @override
  String recordLine(String when, String pos) {
    return '$when · Completed $pos';
  }
}
