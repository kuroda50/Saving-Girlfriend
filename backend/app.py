import os
from flask import Flask, request, jsonify
# openaiとdotenvは、このテスト段階では必須ではありませんが、将来のために残しておきます
import openai
from dotenv import load_dotenv

# .envファイルから環境変数を読み込む
load_dotenv()

# Flaskアプリケーションの初期化
app = Flask(__name__)

# OpenAI APIキーを設定（テスト段階では実際には使用されません）
openai.api_key = os.getenv("OPENAI_API_KEY")


# --- ここが「AIを呼び出したフリ」をするテスト用の関数です ---
def get_ai_reaction(savings_amount: int) -> dict:
    """
    【開発用モック】貯金額に応じた固定のリアクションと感情を返す関数。
    """
    print(f"--- モックモードで動作中 (貯金額: {savings_amount}円) ---")

    # 貯金額に応じて、あらかじめ用意したメッセージと感情を返す
    if savings_amount > 10000:
        return {"reaction": "（すごく喜ぶテストメッセージ）", "emotion": "very_happy"}
    elif savings_amount > 0:
        return {"reaction": "（普通に喜ぶテストメッセージ）", "emotion": "happy"}
    elif savings_amount == 0:
        return {"reaction": "（0円の時のテストメッセージ）", "emotion": "neutral"}
    else: # マイナスの場合
        return {"reaction": "（心配するテストメッセージ）", "emotion": "curious"}


@app.route('/girlfriend_reaction', methods=['POST'])
def girlfriend_reaction_endpoint():
    """
    Flutterアプリから呼び出されるエンドポイント。
    """
    data = request.json
    if not data or 'savings_amount' not in data:
        return jsonify({"error": "savings_amountが必要です"}), 400

    try:
        savings_amount = int(data['savings_amount'])
    except (ValueError, TypeError):
        return jsonify({"error": "savings_amountは整数である必要があります"}), 400

    # モック用の関数を呼び出し、結果をそのまま返す
    response_data = get_ai_reaction(savings_amount)
    return jsonify(response_data)


# Flaskサーバーを起動
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)