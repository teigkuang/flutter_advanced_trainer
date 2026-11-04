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
  String get fieldBpm => 'Tempo BPM';

  @override
  String get bpmHint =>
      'Metronome tempo used on execution (40–208, default 120)';

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
  String get typeSport => 'Sport';

  @override
  String get typeTask => 'Tasks';

  @override
  String get typeStudy => 'Study';

  @override
  String get typeRecord => 'Record';

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
  String get execEnter => 'Execute';

  @override
  String get toastDoneFinish => 'All done — training complete';

  @override
  String get toastAdvance => 'Completed and advanced';

  @override
  String toastFail(String rule) {
    return 'Marked incomplete · $rule';
  }

  @override
  String get fieldListFile => 'List / study file';

  @override
  String get listPickHint => 'Tap to choose a .md / .txt file';

  @override
  String get listFileHint =>
      'Task/Study tasks need a list file, taken in a loop during execution';

  @override
  String get errListEmpty => 'Selected file is empty';

  @override
  String get errListPick => 'Failed to pick file';

  @override
  String toastListUploaded(String name) {
    return 'List \"$name\" uploaded';
  }

  @override
  String get metronomeTitle => 'Metronome';

  @override
  String get metronomeBpm => 'Tempo (BPM)';

  @override
  String get metronomeIdle => 'Ready · tap start';

  @override
  String get metronomePaused => 'Paused';

  @override
  String get metronomeRunning => 'Running';

  @override
  String get metronomeStart => 'Start';

  @override
  String get metronomePause => 'Pause';

  @override
  String get metronomeEnd => 'Finish';

  @override
  String metronomeItem(int ref) {
    return 'This item ref: $ref';
  }

  @override
  String get metronomeBpmHint => 'Tap the number to enter BPM (40–208)';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get checklistTitle => 'Checklist';

  @override
  String get checklistMissing => 'List file missing, please re-upload';

  @override
  String checklistLoop(String file) {
    return 'List: $file · taken in loop, wrap around';
  }

  @override
  String get checklistFileLabel => 'Unnamed list';

  @override
  String checklistNeed(int n) {
    return 'Check $n items';
  }

  @override
  String get checklistFinish => 'All checked · Finish item';

  @override
  String get noteTitle => 'Write a record';

  @override
  String noteNeed(int n) {
    return 'Submit $n entries';
  }

  @override
  String notePos(String pos) {
    return 'Position: $pos';
  }

  @override
  String noteSubmitted(int done, int total) {
    return 'Submitted $done / $total';
  }

  @override
  String get noteHint => 'Write this entry…';

  @override
  String get noteSubmit => 'Submit this entry';

  @override
  String get noteSaving => 'Submitting…';

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

  @override
  String get logDetailTitle => 'Record Detail';

  @override
  String get logDetailContentLabel => 'Content';

  @override
  String get logDetailPosLabel => 'Position';

  @override
  String get logDetailTimeLabel => 'Time';

  @override
  String get logDetailOpen => 'View detail';

  @override
  String noteInSession(int n) {
    return '$n entries in this session';
  }

  @override
  String handledInSession(int n) {
    return '$n items handled';
  }
}
