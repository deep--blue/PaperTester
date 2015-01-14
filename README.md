PaperTester
===========

##概要
InternetExplorer(IE)の操作内容をExcel単体テスト仕様書（PaperTester.xlsx）に記入していくと、
ワークシート関数で自動操作用のVBScriptコードを生成します。
生成されたコードを所定のテンプレートコード（PaperTester.vbs）に埋め込み実行する事で、
IEが自動操作され、
スクリーンショットとSQLスクリプトの実行結果がエビデンス記録ブック（EvidenceTemplate.xlsx）に貼り付けられます。

##デモ
[demoフォルダ](https://github.com/nezuQ/PaperTester/tree/master/demo)をWindowsPCにダウンロードし、ダブルクリックして下さい。
IEが起動し、[デモ用のWebページ](http://bl.ocks.org/nezuQ/raw/9719897/)の画面項目が自動操作されます。
その後、スクリーンショットやダミーデータベース（_database.xlsx）の値がエビデンス記録ブック（EvidenceTemplate.xlsx）に貼り付けられます。

##依存ソフトウェア
 * Windows OS (Vista 以上)
 * Microsoft Office (2007 以上)
 * Internet Explorer (8 以上)

##使い方
 1. PaperTester.xlsxの書き方
   1. テストケース名を記入する。テストケース番号は順番やインデントで自動で割り当てられます。
   2. 確認内容・想定結果を記入する。
   3. 操作名・引数を記入する。入力できる値はdataシートに説明があります。
   4. その他項目を任意で記入する。
 2. PaperTester.vbsへのコードの埋め込み方
   1. PaperTester.xlsxの操作コマンド列の値を一括でコピーし、PaperTester.vbsの"本処理"の箇所に貼り付ける。
   2. 同ファイルの"設定"の箇所にある * CONNECTION_STRING * 変数に接続文字列を記入する。※データベースを操作しない場合は未記入にする。
   3. 上書き保存する。
 3. テストの実行方法
   1. PaperTester.vbsをダブルクリックする。
   2. IE起動時にIEが最前面に来なかった場合は、IEをクリックし、最前面に移動する。
   
##ライセンス
 * MITライセンス

##関連ページ
Qiita - Excelスクショ問題の解決策を現役エンジニアが本気で考えた。
http://qiita.com/nezuq/items/d2ff540cdba00d41bfda  
http://qiita.com/nezuq/items/8b9438108b5195a3c0bf  
