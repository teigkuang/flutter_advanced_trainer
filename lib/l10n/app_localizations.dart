import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Advance Trainer'**
  String get appTitle;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Tear through barriers, strive upward'**
  String get appSlogan;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No training tasks yet'**
  String get emptyTitle;

  /// No description provided for @emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first training item and push through, starting from Level 1'**
  String get emptySubtitle;

  /// No description provided for @emptyCta.
  ///
  /// In en, this message translates to:
  /// **'Create your first training task'**
  String get emptyCta;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusActive;

  /// No description provided for @statusWait.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get statusWait;

  /// No description provided for @createTitle.
  ///
  /// In en, this message translates to:
  /// **'New Training Task'**
  String get createTitle;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Training item name *'**
  String get fieldName;

  /// No description provided for @fieldGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade *'**
  String get fieldGrade;

  /// No description provided for @fieldBeginNum.
  ///
  /// In en, this message translates to:
  /// **'Start number *'**
  String get fieldBeginNum;

  /// No description provided for @fieldPlus.
  ///
  /// In en, this message translates to:
  /// **'Increment *'**
  String get fieldPlus;

  /// No description provided for @fieldBeginGrade.
  ///
  /// In en, this message translates to:
  /// **'Start grade *'**
  String get fieldBeginGrade;

  /// No description provided for @fieldMethod.
  ///
  /// In en, this message translates to:
  /// **'Training method'**
  String get fieldMethod;

  /// No description provided for @fieldGoal.
  ///
  /// In en, this message translates to:
  /// **'Specific goal'**
  String get fieldGoal;

  /// No description provided for @fieldFailRule.
  ///
  /// In en, this message translates to:
  /// **'On failure'**
  String get fieldFailRule;

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bench press'**
  String get hintName;

  /// No description provided for @hintGoal.
  ///
  /// In en, this message translates to:
  /// **'e.g. 50 push-ups daily, 1 min rest between sets'**
  String get hintGoal;

  /// No description provided for @errNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get errNameEmpty;

  /// No description provided for @errNameExists.
  ///
  /// In en, this message translates to:
  /// **'This name already exists'**
  String get errNameExists;

  /// No description provided for @errInvalidParams.
  ///
  /// In en, this message translates to:
  /// **'Enter valid numbers: grade≥1, start number/start grade≥0, increment≥1'**
  String get errInvalidParams;

  /// No description provided for @submitCreate.
  ///
  /// In en, this message translates to:
  /// **'Submit · Create task'**
  String get submitCreate;

  /// No description provided for @toastCreated.
  ///
  /// In en, this message translates to:
  /// **'Created \"{name}\"'**
  String toastCreated(String name);

  /// No description provided for @methodSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get methodSport;

  /// No description provided for @methodStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get methodStudy;

  /// No description provided for @methodTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get methodTask;

  /// No description provided for @methodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get methodOther;

  /// No description provided for @failStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get failStay;

  /// No description provided for @failRecede.
  ///
  /// In en, this message translates to:
  /// **'Recede'**
  String get failRecede;

  /// No description provided for @achievedCount.
  ///
  /// In en, this message translates to:
  /// **'Completed {n} reps'**
  String achievedCount(int n);

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Detail'**
  String get detailTitle;

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// No description provided for @methodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method: {method}'**
  String methodLabel(String method);

  /// No description provided for @goalHint.
  ///
  /// In en, this message translates to:
  /// **'Specific goal: {goal}'**
  String goalHint(String goal);

  /// No description provided for @seqCount.
  ///
  /// In en, this message translates to:
  /// **'Sequence · {count} items'**
  String seqCount(int count);

  /// No description provided for @levelProgress.
  ///
  /// In en, this message translates to:
  /// **'Level progress: {done} / {need} done'**
  String levelProgress(int done, int need);

  /// No description provided for @confirmContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get confirmContinue;

  /// No description provided for @executeTitle.
  ///
  /// In en, this message translates to:
  /// **'Execute Task'**
  String get executeTitle;

  /// No description provided for @todayTarget.
  ///
  /// In en, this message translates to:
  /// **'Complete this session'**
  String get todayTarget;

  /// No description provided for @checkedCount.
  ///
  /// In en, this message translates to:
  /// **'Checked {done} / {total}'**
  String checkedCount(int done, int total);

  /// No description provided for @confirmDone.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Complete'**
  String get confirmDone;

  /// No description provided for @markFail.
  ///
  /// In en, this message translates to:
  /// **'Mark incomplete'**
  String get markFail;

  /// No description provided for @itemIndex.
  ///
  /// In en, this message translates to:
  /// **'Item {index}'**
  String itemIndex(int index);

  /// No description provided for @toastDoneFinish.
  ///
  /// In en, this message translates to:
  /// **'All done — training complete'**
  String get toastDoneFinish;

  /// No description provided for @toastAdvance.
  ///
  /// In en, this message translates to:
  /// **'Completed and advanced'**
  String get toastAdvance;

  /// No description provided for @toastFail.
  ///
  /// In en, this message translates to:
  /// **'Marked incomplete · {rule}'**
  String toastFail(String rule);

  /// No description provided for @gradePosEven.
  ///
  /// In en, this message translates to:
  /// **'Stage {n}'**
  String gradePosEven(int n);

  /// No description provided for @gradePosOdd.
  ///
  /// In en, this message translates to:
  /// **'Stage {n}'**
  String gradePosOdd(int n);

  /// No description provided for @levelPos.
  ///
  /// In en, this message translates to:
  /// **'Level {n}'**
  String levelPos(int n);

  /// No description provided for @repPos.
  ///
  /// In en, this message translates to:
  /// **'Rep {n}'**
  String repPos(int n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
