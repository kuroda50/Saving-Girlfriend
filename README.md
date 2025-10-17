# Saving Girlfriend

家計簿と彼女を組み合わせたアプリ。

## 開発環境のセットアップ

このプロジェクトでは、開発環境のバージョンを統一するために以下のツールを使用しています。

### Node.js (Volta)

[Volta](https://volta.sh/) を使用してNode.jsのバージョンを `22.20.0` に固定しています。

1. **Voltaをインストールします。**
   Windowsの場合、wingetでインストールできます。
   ```sh
   winget install Volta.Volta
   ```
   他のOSについては[公式ドキュメント](https://docs.volta.sh/guide/getting-started)を参照してください。

2. **プロジェクトのNode.jsバージョンをインストールします。**
   `package.json`に記載されたバージョンが自動的にインストール・設定されます。特別なコマンドは不要です。

### Flutter (FVM)

[FVM (Flutter Version Manager)](https://fvm.app/) を使用してFlutterのバージョンを `3.35.6` に統一しています。以下の手順で環境をセットアップしてください。

1.  **FVMをインストールします。**
    ```sh
    dart pub global activate fvm
    ```

2.  **プロジェクト用のFlutter SDKをインストールします。**
    プロジェクトのルートディレクトリで以下のコマンドを実行してください。
    ```sh
    fvm install
    ```
    `.fvm/fvm_config.json` に基づいて、指定されたバージョンのFlutter SDKがダウンロード・設定されます。

3.  **ターミナルを再起動します。**
    FVMの設定を有効にするため、エディタのターミナルなどを再起動してください。

4.  **バージョンを確認します。**
    ```sh
    fvm flutter --version
    ```
    `Flutter 3.35.6` と表示されていればセットアップは完了です。

以降、`flutter` コマンドの代わりに `fvm flutter` を使用してください。（例: `fvm flutter run`, `fvm flutter pub get`）

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

## セットアップと実行方法

### 必要なもの

*   Flutter SDK
*   Dart SDK

### インストール

1.  リポジトリをクローンする
    ```sh
    git clone https://github.com/kuroda50/Saving-Girlfriend
    ```
2.  パッケージをインストールする
    ```sh
    fvm flutter pub get
    ```

3. package.jsonの依存関係をダウンロードする。
    ```sh
    npm install
    ```

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