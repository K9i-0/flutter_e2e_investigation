// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Todo';

  @override
  String get myTasks => 'マイタスク';

  @override
  String get searchTasks => 'タスクを検索...';

  @override
  String get newTask => '新規タスク';

  @override
  String get editTask => 'タスクを編集';

  @override
  String get title => 'タイトル';

  @override
  String get titleHint => '何をする必要がありますか？';

  @override
  String get titleRequired => 'タイトルを入力してください';

  @override
  String get description => '説明';

  @override
  String get descriptionHint => '詳細を追加...';

  @override
  String get category => 'カテゴリ';

  @override
  String get categoryNone => 'なし';

  @override
  String get categoryWork => '仕事';

  @override
  String get categoryPersonal => 'プライベート';

  @override
  String get categoryShopping => '買い物';

  @override
  String get categoryHealth => '健康';

  @override
  String get dueDate => '期限';

  @override
  String get noDueDate => '期限なし';

  @override
  String get attachment => '添付ファイル';

  @override
  String get tapToAddImage => 'タップして画像を追加';

  @override
  String get addImage => '画像を追加';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get takePhotoDescription => 'カメラで画像を撮影';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String get chooseFromGalleryDescription => '既存の画像を選択';

  @override
  String get createTask => 'タスクを作成';

  @override
  String get updateTask => 'タスクを更新';

  @override
  String get deleteTodo => 'Todoを削除';

  @override
  String get deleteTodoConfirmation => 'このTodoを削除してもよろしいですか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get all => 'すべて';

  @override
  String get active => '未完了';

  @override
  String get completed => '完了';

  @override
  String get showCompleted => '完了を表示';

  @override
  String get hideCompleted => '完了を非表示';

  @override
  String get noTasks => 'タスクがありません';

  @override
  String get noTasksDescription => '+ をタップして最初のタスクを追加';

  @override
  String get today => '今日';

  @override
  String get tomorrow => '明日';

  @override
  String get yesterday => '昨日';

  @override
  String inDays(int count) {
    return '$count日後';
  }

  @override
  String daysAgo(int count) {
    return '$count日前';
  }

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get theme => 'テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get appearance => '外観';

  @override
  String get defaults => 'デフォルト設定';

  @override
  String get sortOrder => '並び順';

  @override
  String get sortByCreatedAt => '作成日';

  @override
  String get sortByDueDate => '期限';

  @override
  String get sortByName => '名前';

  @override
  String get showCompletedTasks => '完了タスクを表示';

  @override
  String get defaultCategory => 'デフォルトカテゴリ';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get deleteCompletedTasks => '完了タスクを削除';

  @override
  String get deleteCompletedTasksDescription => 'すべての完了タスクを削除';

  @override
  String get deleteCompletedConfirmation => 'すべての完了タスクを削除しますか？この操作は取り消せません。';

  @override
  String get clearAllData => 'すべてのデータを削除';

  @override
  String get clearAllDataDescription => 'すべてのタスクと設定をリセット';

  @override
  String get clearAllDataConfirmation =>
      'すべてのデータを削除しますか？すべてのタスクが削除され、設定がリセットされます。この操作は取り消せません。';

  @override
  String get about => 'アプリについて';

  @override
  String get version => 'バージョン';

  @override
  String get licenses => 'ライセンス';

  @override
  String get licensesDescription => 'オープンソースライセンスを表示';

  @override
  String tasksDeleted(int count) {
    return '$count件の完了タスクを削除しました';
  }

  @override
  String get dataCleared => 'すべてのデータを削除しました';
}
