# 进阶训练器（Advance Trainer）

> 基于「进阶表」算法模型的训练管理应用。按 **阶 / 级 / 次** 生成先升后降的数字序列，用于循序渐进地提升各项训练阈值。
> 项目理念 tearhan：撕裂壁垒、含泪向上（tear through barriers, bearing tears on the ascent）。

## 技术栈
- Flutter（stable，Dart）+ Android
- 本地数据层：SQLite（sqflite），复刻算法仓三表：`training_item` / `progress` / `completion_log`
- 算法：在 `lib/engine/` 内用 Dart 完整移植自 Java 算法仓（`E:\Grader\advanced-trainer`），Java 仓为权威维护源
- 多语言：Flutter 官方 `gen-l10n`（简体中文 / 英文），默认中文，仅系统明确为英文时切英文
- 应用名固定中文「进阶训练器」

## 目录结构
```
lib/
  engine/          算法核心（models / progress_engine）
  data/            数据层（app_database / training_repository）
  ui/              界面（home / create / detail / execute / theme / app_scope / title_format）
  l10n/            本地化（app_zh.arb / app_en.arb + 生成代码）
  main.dart        入口
test/              测试（算法 16 条 + 语言解析 4 条）
android/           Android 工程（应用名 / 图标 / 资源）
assets/icon/       应用图标素材
```

## 构建环境
| 组件 | 路径 / 说明 |
|---|---|
| Flutter SDK | `D:\IDE\flutter`（命令行 `flutter` 已可用） |
| Android SDK | `D:\android_sdk` |
| 项目根 | `E:\Grader\TrainerApp\code\advance_trainer` |

## 日常构建流程
在项目目录打开 PowerShell：

```powershell
cd E:\Grader\TrainerApp\code\advance_trainer

# 1. 拉依赖（新 clone 或加了依赖后必跑）
flutter pub get

# 2. 改了语言词条后重新生成本地化代码
flutter gen-l10n

# 3. 静态检查（改完代码先跑，保证无报错）
flutter analyze

# 4. 跑测试（16 条算法 + 4 条语言解析）
flutter test

# 5. 编译 Android Release APK
flutter build apk --release
```

编译产物：`build\app\outputs\flutter-apk\app-release.apk`（约 53.5MB，debug 签名），即要安装到手机的 APK。

## 常改哪里
| 想改什么 | 改哪个文件 |
|---|---|
| 界面文字（中/英） | `lib\l10n\app_zh.arb`（中文）、`lib\l10n\app_en.arb`（英文）→ 再跑 `flutter gen-l10n` |
| 桌面应用名 | `android\app\src\main\res\values\strings.xml`（默认中文） |
| 应用图标 | `assets\icon\` 素材 + `pubspec.yaml` 的 `flutter_launcher_icons` 段，再跑 `dart run flutter_launcher_icons` |
| 算法逻辑 | `lib\engine\progress_engine.dart`、`lib\engine\models.dart` |
| 数据库结构 | `lib\data\app_database.dart` |
| 界面/交互 | `lib\ui\` 下对应页面 |

## 版本管理
```powershell
git add -A
git commit -m "说明"
git log --oneline          # 查看提交历史
git push / git pull        # 本地或 GitHub 同步
```

## 已知限制
- Windows 桌面版（`flutter build windows`）因系统开发者模式未开启、VS Build Tools 不完整，当前不可构建；如需桌面版请先开启开发者模式。
- 当前 APK 为 debug 签名，仅供自用安装；如需上架可后续配置 release 签名。
- 应用暂不接后台服务与账号系统（架构已预留替换缝，见 `TrainingRepository` 抽象）。
