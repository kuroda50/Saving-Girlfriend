# Saving Girlfriend

家計簿と彼女を組み合わせたアプリ。

## 主な機能

*   彼女と会話する
*   収支を入力する
*   彼女を選択する
*   ストーリーを視聴する
*   家計簿の履歴を見る

## 技術スタック

*   **フレームワーク:** [Flutter](https://flutter.dev/)
*   **状態管理:** [Riverpod](https://riverpod.dev/)
*   **画面遷移:** [go_router](https://pub.dev/packages/go_router)
*   **ローカルストレージ:** [shared_preferences](https://pub.dev/packages/shared_preferences)

## 開発環境のセットアップ

このプロジェクトでは、開発環境のバージョンを統一するために **Volta** と **FVM** を使用します。

### 1. 前提ツールのインストール

#### Node.js (Volta)
[Volta](https://volta.sh/) を使用してNode.jsのバージョンを固定します。
[公式ドキュメント](https://docs.volta.sh/guide/getting-started)を参考にVoltaをインストールしてください。
Windowsの場合、wingetでインストールできます。
```sh
winget install Volta.Volta
```

#### Flutter (FVM)
[FVM (Flutter Version Manager)](https://fvm.app/) を使用してFlutterのバージョンを統一します。
```sh
dart pub global activate fvm
```

### 2. プロジェクトのセットアップ

1. **リポジトリをクローンする**
   ```sh
   git clone https://github.com/kuroda50/Saving-Girlfriend
   ```
   クローン後、プロジェクトディレクトリに移動してください。

2. **Flutter SDK と Node.js のバージョンをインストールする**
   FVM と Volta がインストールされていれば、プロジェクトで必要なバージョンが自動的に認識されます。
   以下のコマンドで、Flutter SDKをインストールしてください。
   ```sh
   fvm install
   ```
   ターミナルを再起動すると、FVMの設定が有効になります。

3. **依存関係をインストールする**
   Flutter と npm のパッケージをインストールします。
   ```sh
   fvm flutter pub get
   npm install
   ```

### 3. セットアップの確認
以下のコマンドを実行し、バージョンが表示されればセットアップは完了です。
```sh
fvm flutter --version
```
`Flutter 3.35.6` と表示されるはずです。

以降、`flutter` コマンドの代わりに `fvm flutter` を使用してください。（例: `


---

## 主な機能

*   彼女と会話する
*   収支を入力する
*   彼女を選択する
*   ストーリーを視聴する
*   家計簿の履歴を見る

## 技術スタック

*   **フレームワーク:** [Flutter](https://flutter.dev/)
*   **状態管理:** [Riverpod](https://riverpod.dev/)
*   **画面遷移:** [go_router](https://pub.dev/packages/go_router)
*   **ローカルストレージ:** [shared_preferences](https://pub.dev/packages/shared_preferences)

### アプリケーションの実行

```sh
fvm flutter run
```

## ディレクトリ構成とアーキテクチャ

このプロジェクトでは、MVVM + Feature-base アーキテクチャを採用しています。これにより、コードの可読性、保守性、拡張性を高めています。

### 主要なディレクトリ構成

```
.
├── lib/
│   ├── app/                  # アプリケーション全体を構成する層
│   │   ├── providers/        # 複数のFeatureを統合するProvider (例: spendableAmountProvider)
│   │   ├── route/            # アプリケーション全体のルーティング定義 (go_router.dart, app_navigation_bar.dart)
│   │   └── screens/          # 複数のFeatureを組み合わせて表示する画面 (例: HomeScreen)
│   │
│   ├── features/             # 各機能（Feature）を独立して管理する層
│   │   ├── live_stream/      # ライブ配信風UI (コメント表示、キャラクターセリフ)
│   │   │   ├── models/
│   │   │   ├── providers/
│   │   │   └── widgets/
│   │   │
│   │   ├── story/            # ストーリーの選択・再生機能
│   │   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   ├── screens/
│   │   │   └── services/
│   │   │
│   │   ├── settings/         # アプリケーション設定の管理
│   │   │   ├── models/
│   │   │   ├── providers/
│   │   │   ├── repositories/
│   │   │   └── screens/
│   │   │
│   │   ├── transaction/      # 収支入力・履歴表示機能
│   │   │   ├── models/
│   │   │   ├── providers/
│   │   │   ├── repositories/
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── utils/
│   │   │
│   │   ├── tribute/          # 貢ぐ（スパチャ）機能
│   │   │   ├── models/
│   │   │   ├── providers/
│   │   │   ├── repositories/
│   │   │   └── widgets/
│   │   │
│   │   └── budget/           # 予算管理機能
│   │       ├── models/
│   │       └── providers/
│   │
│   └── common/               # 汎用的でFeatureに依存しない共通部品
│       ├── constants/        # アプリ全体で利用する定数 (assets, colorなど)
│       ├── models/           # 複数のFeatureで共有されるモデル (Character, Messageなど)
│       ├── providers/        # 汎用的なProvider (uuidProvider, particleProviderなど)
│       ├── services/         # 汎用的なサービス (LocalStorageService, NotificationServiceなど)
│       ├── utils/            # 汎用的なユーティリティ関数 (dialog_utilsなど)
│       └── widgets/          # 汎用的なUIコンポーネント (effectsなど)
```

### ディレクトリ間の依存関係

このアーキテクチャでは、以下の厳格な依存関係のルールを設けることで、コードのモジュール性と保守性を高めています。

-   **`app`レイヤー**:
    -   `features`レイヤーと`common`レイヤーのコンポーネントを`import`して利用できます。
    -   アプリケーション全体のルーティングや、複数のFeatureを統合する画面・ロジックを担います。

-   **`features`レイヤー**:
    -   `common`レイヤーのコンポーネントを`import`して利用できます。
    -   **他の`features`レイヤーのコンポーネントを直接`import`すべきではありません。**
    -   各Featureは自己完結しており、特定の機能に特化したロジックとUIを含みます。

-   **`common`レイヤー**:
    -   **他のどのレイヤーのコンポーネントも`import`すべきではありません。** （Dart/Flutter SDKのライブラリは除く）
    -   アプリケーション全体で利用される、汎用的でFeatureに依存しない共通部品を提供します。
