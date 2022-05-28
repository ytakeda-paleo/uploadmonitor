#!/bin/sh

#configファイルの読み込み
. ./uploadmonitor-config.sh

#Chartwork送信の関数
function chatwork(){
curl -X POST -H "X-ChatWorkToken: $CHATWORK_API_KEY" --data-urlencode "body=$TEXT" "https://api.chatwork.com/v2/rooms/$CHATWORK_ROOM_ID/messages"
}

#ファイル数確認の関数
function checkimages(){
cd ${DIR_PATH[2]}
#LATESTFILES=`ls -l | wc -l` <<< too heavy
#LATESTFILES=`find -type f | wc -l` <<< error at MacOS terminal
LATESTFILES=`find . -type f | wc -l`
if [ "$LATESTFILES" -le "$PREVIOUSFILES" ]; then
TEXT="警告：${TIME[2]} 分以上画像の追加がありません．フォルダ：2"
chatwork
cd 
echo $LATESTFILES > ${FILE_LOG[2]}
else
cd 
echo $LATESTFILES > ${FILE_LOG[2]}
fi
}

#監視対象フォルダの存在確認
if [ ! -d "${DIR_PATH[2]}" ]; then
TEXT="監視に失敗しました：保存先フォルダが見つかりません．保存先フォルダを指定しなおしてください．フォルダ：2"
chatwork
exit
else
:
fi

#LOGファイルの存在確認
if [ ! -f "${FILE_LOG[2]}" ]; then
TEXT="監視に失敗しました：logファイルが見つかりません．管理者に問い合わせてください．フォルダ：2"
chatwork
exit
else
#LOGファイルの読み込み
PREVIOUSFILES=$(<${FILE_LOG[2]})
fi

checkimages

if [ $? -gt 0 ]; then
TEXT="監視に失敗しました：uploadmonitor2.shが実行できませんでした．管理者に問い合わせてください．フォルダ：2"
chatwork
fi
