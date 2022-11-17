# uploadmonitor   
_English version in prep._
The scripts are developed by Yusuke Takeda([@ytakeda-paleo](https://github.com/ytakeda-paleo)) and Yasuhiro Iba.

## 概要
- 数分間隔で継続的にファイルを特定のフォルダに送信するような処理を行っている時に，その処理が止まっていないかモニタリングします．
- 監視先のフォルダは3つ選べます．
- 監視する時間間隔は1,2,3,4,5,6,12,15,20,30分，または，1時間以上（1時間単位）で設定できます．
- ファイルが指定したフォルダに送信されていなければ（フォルダ内のファイル数が増えていなければ），チャットワークに通知します．
- MacOS向けに制作しています．LinuxやWindowsでも動作すると思いますが部分的に修正する必要があるかもしれません，

## MacOSへの導入方法（初心者向け）
- 今見ているこのサイト( https://github.com/ytakeda-paleo/num-files-monitor )からcode→download zipでスクリプトをダウンロードしてください．
- ダウンロードしたzipを展開してください．
- jaフォルダ内のファイルをすべて，Macのホームディレクトリ（Finder→ユーザー→hogehoge（例））にペーストしてください．
  - フォルダごとペーストではなく，フォルダ内のファイルのみペーストします．
- ターミナルアプリを起動し，（カレントディレクトリがホームディレクトリの状態で）以下を入力します．
  - `sudo chmod +x *.sh`
- MacOSの「システム環境設定」の「セキュリティとプライバシー」にある「フルディスクアクセス」「ファイルとフォルダ」「デベロッパツール」に「ターミナル」アプリ（アプリ>ユーティリティ)を追加して許可してください．
  - 「フルディスクアクセス」に追加すると「ファイルとフォルダ」にも自動的に追加されるはずです．
- MacOSの「システム環境設定」の「セキュリティとプライバシー」にある「フルディスクアクセス」「ファイルとフォルダ」に「cron」を追加して許可してください．
  - ファイル選択のダイアログで [command] + [shift] + [G] を押すと，フォルダへ移動するボックスがあらわれるので，`/usr/sbin/cron` と入力して表示される`cron`を追加します.
- `uploadmonitor-config.sh`をテキストエディット（または他のエディタアプリ）で開いて，以下の箇所を編集します．
  - `FILE_LOG[1][2][3]`,`EXE[1][2][3]`,`CRON[1][2][3]`内のhogehogeを自分のユーザー名に置き換えてください．
  - `CHATWORK_API_KEY="put-api-key-here"`と`CHATWORK_ROOM_ID="put-room-id-here"`に，APIキーとルームIDを入力してください．
- `uploadmonitor-settings.sh`を同様に開いて，以下を箇所を編集します．
  - 131行目と134行目のhogehogeを自分のユーザー名に置き換えてください．

## 起動方法
- ターミナルアプリを起動し，（カレントディレクトリがホームディレクトリの状態で）以下を入力します．   
` sh uploadmonitor-settings.sh`   
- 表示画面に従って，フォルダ番号を入力し，操作します．
- 終了時はCtrl + X で終了します．

## 補足
- 監視オン直後にアラートが発生することがありますが，処理上の仕様です．(crontabで実行しているためです)
- Windows→iMacにUSBメモリ経由でスクリプトファイルをコピペする，といったことは避けてください（OS間で改行コードが異なるので，単純にこの方法でペーストしたスクリプトは動きません）
- シェルスクリプトで作った意図：python2しか入っていない古いiMacで起動させるため（python3をインストールしたくなかった）
- 仕組み：crontabで`find . -type f | wc -l`で指定フォルダ内のファイル数をカウントし，一つ前のサイクルにカウントしたファイル数（これはテキストファイルとして保存されます）と比較．ファイル数が増えていなければアラートを出します．

## Overview
- When a process is continuously sending files to a specific folder at intervals of several minutes, this function monitors whether the process is stopped or not.
- You can select up to three folders to monitor.
- The monitoring interval can be set to 1, 2, 3, 4, 5, 6, 12, 15, 20, 30 minutes, or more than 1 hour (in 1-hour increments).
- If a file has not been sent to the specified folder (or if the number of files in the folder has not increased), Chatwork will be notified.
- This application is designed for MacOS; it should also work on Linux and Windows, but some modifications may be necessary.

## How to install on MacOS (for beginners)
- Download the script from this site ( https://github.com/ytakeda-paleo/num-files-monitor ) that you are looking at now by clicking code→download zip.
- Extract the downloaded zip.
- Paste all the files in the ja folder into your Mac home directory (Finder→User→hogehoge (example)).
  - Paste only the files in the folder, not the whole folder.
- Start the Terminal application (with the current directory as the home directory) and type the following.
  - `sudo chmod +x *.sh`.
- Add the "Terminal" application (Apps>Utilities) to "Full Disk Access", "Files and Folders", and "Developer Tools" in "Security and Privacy" in the "System Preferences" of MacOS and allow it.
  - If you add it to "Full Disk Access", it should be automatically added to "Files and Folders" as well.
- Add "cron" to "Full Disk Access" and "Files and Folders" in "Security and Privacy" in "System Preferences" of MacOS and allow it.
  - In the file selection dialog, press [command] + [shift] + [G] to bring up a box to go to the folder, type `/usr/sbin/cron` and add `cron` that appears.
- Open `uploadmonitor-config.sh` with a text editor (or other editor application) and edit the following sections.
  - Replace hogehoge in `FILE_LOG[1][2][3]`,`EXE[1][2][3]`,`CRON[1][2][3]` with your user name.
  - Enter your API key and room ID in `CHATWORK_API_KEY="put-api-key-here"` and `CHATWORK_ROOM_ID="put-room-id-here"`.
- Open `uploadmonitor-settings.sh` in the same way, and edit the following sections.
  - Replace hogehoge in lines 131 and 134 with your user name.
  
## How to start
- Start the terminal application and enter the following (with the current directory being your home directory)   
` sh uploadmonitor-settings.sh`.   
- Enter the folder number according to the display screen.
- To exit, press Ctrl + X.

## Supplemental
- An alert may occur immediately after monitoring is turned on. (This is due to the fact that it is executed in crontab.)
- Please avoid copying and pasting script files from Windows to iMac via USB memory stick (scripts pasted in this way simply will not work because line feed codes are different between operating systems).
- Intention of using a shell script: To run on an old iMac with only python2 (I didn't want to install python3).
- How it works: In crontab, I run `find . -type f | wc -l` to count the number of files in the specified folder and compare it with the number of files counted in the previous cycle (which is saved as a text file). If the number of files has not increased, an alert is issued.
