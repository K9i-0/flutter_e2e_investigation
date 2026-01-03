import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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
    Locale('ja'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get appTitle;

  /// Header for the task list
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// Placeholder for search field
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasks;

  /// Title for new task screen
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// Title for edit task screen
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// Label for title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Hint text for title field
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get titleHint;

  /// Validation message for empty title
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Hint text for description field
  ///
  /// In en, this message translates to:
  /// **'Add some details...'**
  String get descriptionHint;

  /// Label for category selection
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Option for no category
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get categoryNone;

  /// Work category name
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// Personal category name
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get categoryPersonal;

  /// Shopping category name
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// Health category name
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// Label for due date picker
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Text when no due date is set
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// Label for image attachment
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// Placeholder text for image attachment
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get tapToAddImage;

  /// Title for image source dialog
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// Option to take photo
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Description for take photo option
  ///
  /// In en, this message translates to:
  /// **'Use camera to capture an image'**
  String get takePhotoDescription;

  /// Option to choose from gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Description for gallery option
  ///
  /// In en, this message translates to:
  /// **'Select an existing image'**
  String get chooseFromGalleryDescription;

  /// Button text to create task
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTask;

  /// Button text to update task
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get updateTask;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Todo'**
  String get deleteTodo;

  /// Confirmation message for delete
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this todo?'**
  String get deleteTodoConfirmation;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Filter option for all tasks
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Filter option for active tasks
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Filter option for completed tasks
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Toggle to show/hide completed tasks
  ///
  /// In en, this message translates to:
  /// **'Show completed'**
  String get showCompleted;

  /// Toggle to hide completed tasks
  ///
  /// In en, this message translates to:
  /// **'Hide completed'**
  String get hideCompleted;

  /// Message when there are no tasks
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasks;

  /// Description for empty state
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first task'**
  String get noTasksDescription;

  /// Date label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Date label for tomorrow
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Date label for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Date label for future days
  ///
  /// In en, this message translates to:
  /// **'In {count} days'**
  String inDays(int count);

  /// Date label for past days
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Defaults section title
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get defaults;

  /// Sort order setting label
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrder;

  /// Sort by creation date option
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get sortByCreatedAt;

  /// Sort by due date option
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get sortByDueDate;

  /// Sort by name option
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// Setting to show completed tasks
  ///
  /// In en, this message translates to:
  /// **'Show Completed Tasks'**
  String get showCompletedTasks;

  /// Default category setting label
  ///
  /// In en, this message translates to:
  /// **'Default Category'**
  String get defaultCategory;

  /// Data management section title
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Option to delete completed tasks
  ///
  /// In en, this message translates to:
  /// **'Delete Completed Tasks'**
  String get deleteCompletedTasks;

  /// Description for delete completed tasks
  ///
  /// In en, this message translates to:
  /// **'Remove all completed tasks'**
  String get deleteCompletedTasksDescription;

  /// Confirmation for deleting completed tasks
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all completed tasks? This action cannot be undone.'**
  String get deleteCompletedConfirmation;

  /// Option to clear all data
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// Description for clear all data
  ///
  /// In en, this message translates to:
  /// **'Delete all tasks and reset settings'**
  String get clearAllDataDescription;

  /// Confirmation for clearing all data
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all data? This will remove all tasks and reset settings. This action cannot be undone.'**
  String get clearAllDataConfirmation;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Licenses option
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Description for licenses option
  ///
  /// In en, this message translates to:
  /// **'View open source licenses'**
  String get licensesDescription;

  /// Message after deleting completed tasks
  ///
  /// In en, this message translates to:
  /// **'{count} completed tasks deleted'**
  String tasksDeleted(int count);

  /// Message after clearing all data
  ///
  /// In en, this message translates to:
  /// **'All data has been cleared'**
  String get dataCleared;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
