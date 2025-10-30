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

## ディレクトリ構成

```
.
├── android
├── assets
│   └── images
├── backend
├── build
├── ios
├── lib
│   ├── components
│   ├── constants
│   ├── providers
│   ├── route
│   ├── screen
│   ├── services
│   └── widgets
├── linux
├── macos
├── test
├── web
└── windows
```