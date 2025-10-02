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
    flutter pub get
    ```

3. package.jsonの依存関係をダウンロードする。
    ```sh
    npm install
    ```

### アプリケーションの実行

```sh
flutter run
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
