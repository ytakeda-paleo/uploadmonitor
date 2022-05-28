#!/bin/sh

#Chartwork送信の関数
function chatwork(){
curl -X POST -H "X-ChatWorkToken: $CHATWORK_API_KEY" --data-urlencode "body=$NOTICE" "https://api.chatwork.com/v2/rooms/$CHATWORK_ROOM_ID/messages"
}

echo "ファイルアップロード監視ツール設定画面"
echo "####################################################################################################"


#現在の状態を表示させる
#forで回してlane1,2,3を順次表示させたい
function status(){
for i in 1 2 3
do
#CONFIGファイルの存在確認,OKなら読み込み
if [ ! -f ./uploadmonitor-config.sh ]; then
TEXT="エラー：configファイルが見つかりません．管理者に問い合わせてください．フォルダ：${i}"
else
. ./uploadmonitor-config.sh
fi

#LOGファイルの存在確認,OKなら読み込み
if [ ! -f ${FILE_LOG[i]} ]; then
TEXT="エラー：logファイルが見つかりません．管理者に問い合わせてください．フォルダ：${i}"
else
TEXT="設定の異常なし"
fi

#監視対象フォルダの存在確認,OKなら読み込み
if [ ! -d "${DIR_PATH[i]}" ]; then
TEXT="設定されている保存先フォルダが見つかりません．保存先フォルダを指定しなおしてください"
else
TEXT="設定の異常なし"
fi

echo "####################################################################################################"
echo "フォルダ：${i}"
echo "画像の保存先フォルダ：${DIR_PATH[i]}"
echo "フォルダ監視：${TASK[i]}"
echo "(監視ONの場合の)監視の時間間隔：${TIME[i]} 分"
echo $TEXT
echo "####################################################################################################"

done
}

function chooselane(){
echo "変更したいフォルダ番号を入力してください(1/2/3)"
echo "終了する場合はCtrl+Cを押してからターミナルを閉じてください"
read INPUT_LANE
if [ $INPUT_LANE -eq 1 ]; then
echo "フォルダ：${INPUT_LANE}の設定を変更します"
choosemodify
elif [ $INPUT_LANE -eq 2 ]; then
echo "フォルダ：${INPUT_LANE}の設定を変更します"
choosemodify
elif [ $INPUT_LANE -eq 3 ]; then
echo "フォルダ：${INPUT_LANE}の設定を変更します"
choosemodify
else
echo "1または2または3を入力してください"
chooselane
fi
}

function choosemodify(){
echo "変更したい項目の番号を入力してください"
echo "1 :画像の保存先フォルダ"
echo "2 :フォルダ監視のオン(監視時間間隔の変更)"
echo "3 :フォルダ監視のオフ"
read INPUT_MODIFY
if [ $INPUT_MODIFY -eq 1 ]; then
echo "フォルダ：${INPUT_LANE}の画像保存先フォルダを変更します"
changedir
elif [ $INPUT_MODIFY -eq 2 ]; then
echo "フォルダ：${INPUT_LANE}のフォルダ監視時間間隔を設定し，監視をオンにします"
cronon
elif [ $INPUT_MODIFY -eq 3 ]; then
echo "フォルダ：${INPUT_LANE}のフォルダ監視をオフにします"
cronoff
else
echo "1または2または3を入力してください"
choosemodify
fi
}

function changedir(){
echo "フォルダ：${INPUT_LANE}の新しい画像保存先フォルダを入力してください"
echo "例：/Volumes/3/20200606"
read INPUT_DIR
if [ ! -d "$INPUT_DIR" ]; then
echo "入力された保存先フォルダは見つかりません．保存先フォルダを指定しなおしてください"
changedir
else
echo="入力したフォルダが確認されました"
DIR_PATH[$INPUT_LANE]="$INPUT_DIR"
echo "保存先フォルダを${DIR_PATH[${INPUT_LANE}]}に変更しました"
NOTICE="フォルダ：${INPUT_LANE}の保存先フォルダを${DIR_PATH[${INPUT_LANE}]}に変更しました．監視を始める場合は，【フォルダ監視：ON】にしてください．"
chatwork
save
status
chooselane
fi
}

function cronon(){
echo "フォルダ：${INPUT_LANE}のフォルダ監視の間隔(分)を入力してください"
read INPUT_TIME
PARAM_1=0
#### 引数の長さが 0 でなければ、
#### PARAM_1 にそれをセット
if [ ! -z $1 ]; then
    PARAM_1=$INPUT_TIME
fi
#### PARAM_1 に + 1 をし、その戻り値を RET に保存
expr $PARAM_1 + 1 > /dev/null 2>&1
RET=$?

#### 戻り値を使って正常か異常か判定
if [ $RET -lt 2 ]; then
    echo "OK! 数字が入力されました"
else
    echo "数字を入力してください"
    cronon
fi

#CRON[$INPUT_LANE]="*/5 * * * *"
if [ $((60 % $INPUT_TIME)) == 0 ]; then
    CRON[$INPUT_LANE]="*/"$INPUT_TIME" * * * * /Users/hogehoge/uploadmonitor$INPUT_LANE.sh"
elif [ $(($INPUT_TIME % 60)) == 0 ]; then
    INPUT_HOUR=`expr $INPUT_TIME / 60`
    CRON[$INPUT_LANE]="00 */"$INPUT_HOUR" * * * /Users/hogehoge/uploadmonitor$INPUT_LANE.sh"
else
    echo "60分以上は60分単位で設定可能です．60の倍数を入力してください"
    cronon
fi

echo "${CRON[1]}" > uploadmonitor_crontab_temp.txt
echo "${CRON[2]}" >> uploadmonitor_crontab_temp.txt
echo "${CRON[3]}" >> uploadmonitor_crontab_temp.txt
crontab uploadmonitor_crontab_temp.txt
echo "フォルダ：${INPUT_LANE}の${INPUT_TIME}分間隔のフォルダ監視をオンにします"
TIME[$INPUT_LANE]="$INPUT_TIME"
TASK[$INPUT_LANE]="ON"
LATESTFILES="0"
echo $LATESTFILES > ${FILE_LOG[$INPUT_LANE]}
echo "Chatworkにも投稿しました"
NOTICE="フォルダ：${INPUT_LANE}の${INPUT_TIME}分間隔のフォルダ監視を開始しました．保存先フォルダ：${DIR_PATH[${INPUT_LANE}]}"
chatwork
save
status
chooselane
}

function cronoff(){
CRON[$INPUT_LANE]=" "
echo "フォルダ：${INPUT_LANE}のフォルダ監視を終了します"
echo "${CRON[1]}" > uploadmonitor_crontab_temp.txt
echo "${CRON[2]}" >> uploadmonitor_crontab_temp.txt
echo "${CRON[3]}" >> uploadmonitor_crontab_temp.txt
crontab uploadmonitor_crontab_temp.txt
TASK[$INPUT_LANE]="OFF"
echo "Chatworkにも投稿しました"
NOTICE="フォルダ：${INPUT_LANE}のフォルダ：${DIR_PATH[${INPUT_LANE}]}の監視を終了しました"
chatwork
save
status
chooselane
}

function save(){
echo ""#!/bin/sh"\nDIR_PATH[1]=\"${DIR_PATH[1]}\"\nDIR_PATH[2]=\"${DIR_PATH[2]}\"\nDIR_PATH[3]=\"${DIR_PATH[3]}\"\nTIME[1]=\"${TIME[1]}\"\nTIME[2]=\"${TIME[2]}\"\nTIME[3]=\"${TIME[3]}\"\nTASK[1]=\"${TASK[1]}\"\nTASK[2]=\"${TASK[2]}\"\nTASK[3]=\"${TASK[3]}\"\nFILE_LOG[1]=\"${FILE_LOG[1]}\"\nFILE_LOG[2]=\"${FILE_LOG[2]}\"\nFILE_LOG[3]=\"${FILE_LOG[3]}\"\nEXE[1]=\"${EXE[1]}\"\nEXE[2]=\"${EXE[2]}\"\nEXE[3]=\"${EXE[3]}\"\nCRON[1]=\"${CRON[1]}\"\nCRON[2]=\"${CRON[2]}\"\nCRON[3]=\"${CRON[3]}\"\nCHATWORK_API_KEY=\"$CHATWORK_API_KEY\"\nCHATWORK_ROOM_ID=\"$CHATWORK_ROOM_ID\"\nCHATWORK_MESSAGE_HEADER=\"$CHATWORK_MESSAGE_HEADER\"\nCHATWORK_MESSAGE_MESSAGE=\"$CHATWORK_MESSAGE_MESSAGE\"\nCHATWORK_MESSAGE_FOOTER=\"$CHATWORK_MESSAGE_FOOTER\"" > uploadmonitor-config.sh
echo "現在の設定状態を保存しました"
}

status
chooselane
#lane番号を選んで→設定する項目を選んで→変更
