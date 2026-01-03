// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Todo';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get searchTasks => 'Search tasks...';

  @override
  String get newTask => 'New Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'What needs to be done?';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'Add some details...';

  @override
  String get category => 'Category';

  @override
  String get categoryNone => 'None';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHealth => 'Health';

  @override
  String get dueDate => 'Due Date';

  @override
  String get noDueDate => 'No due date';

  @override
  String get attachment => 'Attachment';

  @override
  String get tapToAddImage => 'Tap to add image';

  @override
  String get addImage => 'Add Image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get takePhotoDescription => 'Use camera to capture an image';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get chooseFromGalleryDescription => 'Select an existing image';

  @override
  String get createTask => 'Create Task';

  @override
  String get updateTask => 'Update Task';

  @override
  String get deleteTodo => 'Delete Todo';

  @override
  String get deleteTodoConfirmation =>
      'Are you sure you want to delete this todo?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Completed';

  @override
  String get showCompleted => 'Show completed';

  @override
  String get hideCompleted => 'Hide completed';

  @override
  String get noTasks => 'No tasks yet';

  @override
  String get noTasksDescription => 'Tap + to add your first task';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String inDays(int count) {
    return 'In $count days';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get appearance => 'Appearance';

  @override
  String get defaults => 'Defaults';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get sortByCreatedAt => 'Created Date';

  @override
  String get sortByDueDate => 'Due Date';

  @override
  String get sortByName => 'Name';

  @override
  String get showCompletedTasks => 'Show Completed Tasks';

  @override
  String get defaultCategory => 'Default Category';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get deleteCompletedTasks => 'Delete Completed Tasks';

  @override
  String get deleteCompletedTasksDescription => 'Remove all completed tasks';

  @override
  String get deleteCompletedConfirmation =>
      'Are you sure you want to delete all completed tasks? This action cannot be undone.';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataDescription => 'Delete all tasks and reset settings';

  @override
  String get clearAllDataConfirmation =>
      'Are you sure you want to delete all data? This will remove all tasks and reset settings. This action cannot be undone.';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get licenses => 'Licenses';

  @override
  String get licensesDescription => 'View open source licenses';

  @override
  String tasksDeleted(int count) {
    return '$count completed tasks deleted';
  }

  @override
  String get dataCleared => 'All data has been cleared';
}
