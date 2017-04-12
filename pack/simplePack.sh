#!/bin/sh
PRG=$0
CURRENT_DIR="`dirname $PRG`"
ABS_DIR="`cd $CURRENT_DIR;pwd`"

CODESIGN_EXEC="/usr/bin/codesign"
PLIST_BUDDY_EXEC="/usr/libexec/PlistBuddy"
SIGNING_IDENTITY="iPhone Distribution: Neijiang Fenghuang Enterprise (Group) Co., Ltd."
PROVISIONING_PROFILE="$ABS_DIR/../ProvisioningProfile/HoneyLive27InHouseProvisioningProfile.mobileprovision"

PROJECT_NAME=$1
MIN_PKG_NO=$2
MAX_PKG_NO=$3

PARENT_PACKAGE="${ABS_DIR}/${PROJECT_NAME}.ipa"
PROJECT_APP_NAME="${PROJECT_NAME}.app"
CHANNEL_PREFIX="IOS_A_I" #iOS主包
#CHANNEL_PREFIX="H5-0000" #H5

IPA_STORAGE_DIR="$ABS_DIR/ipas"


[ -d "$IPA_STORAGE_DIR" ] && rm -rf $IPA_STORAGE_DIR

mkdir -p $IPA_STORAGE_DIR

SIGNED_IPA_STORAGE_DIR="$ABS_DIR/ipas_signed"

[ ! -d "$SIGNED_IPA_STORAGE_DIR" ] && mkdir -p $SIGNED_IPA_STORAGE_DIR


PAYLOAD="$ABS_DIR/Payload"

[ -d "$PAYLOAD" ] && rm -rf $PAYLOAD

unzip $PARENT_PACKAGE -d $ABS_DIR/ > /dev/null

WORKSPACE="$ABS_DIR/workspace"

[ -d "$WORKSPACE" ] && rm -rf $WORKSPACE

mkdir -p $WORKSPACE

THREAD_NUM=10

mkfifo packpipe
exec 9<>packpipe

rm packpipe

for i in `eval echo {1..$THREAD_NUM}`; do
unzip $PARENT_PACKAGE -d "$WORKSPACE/Payload_`printf "%2d" $i | tr " " 0`/" > /dev/null
#cp -rfp $PAYLOAD "$WORKSPACE/Payload_`printf "%2d" $i | tr " " 0`/"
echo "$i" 1>&9
done

while [ $MIN_PKG_NO -le $MAX_PKG_NO ]; do
read -u 9 seq
{
MIN_PKG_NO_PADDING="`printf "%3d" $MIN_PKG_NO | tr " " 0`"
CURRENT_PKG_STORAGE_DIR="$IPA_STORAGE_DIR/$MIN_PKG_NO_PADDING"
[ -d "$CURRENT_PKG_STORAGE_DIR" ] && rm -rf $CURRENT_PKG_STORAGE_DIR
mkdir -p $CURRENT_PKG_STORAGE_DIR

IPA_FILE="$CURRENT_PKG_STORAGE_DIR/${PROJECT_NAME}.ipa"
CHANNELNO="$CHANNEL_PREFIX`printf "%8d" $MIN_PKG_NO | tr " " 0`" #iOS主包
#        CHANNELNO="$CHANNEL_PREFIX`printf $MIN_PKG_NO | tr " " 0`" #H5
CONFIG_PLIST_FILE="$WORKSPACE/Payload_`printf "%2d" $seq | tr " " 0`/Payload/${PROJECT_APP_NAME}/ChannelNo.plist"
$PLIST_BUDDY_EXEC -c "set :ChannelNo ${CHANNELNO}" $CONFIG_PLIST_FILE
ZIP_DIR="$WORKSPACE/Payload_`printf "%2d" $seq | tr " " 0`/Payload"
cd $ZIP_DIR
cd ..
rm -rf Payload/${PROJECT_NAME}.app/_CodeSignature
cp "${PROVISIONING_PROFILE}" "Payload/${PROJECT_NAME}.app/embedded.mobileprovision"
$CODESIGN_EXEC -f -s "${SIGNING_IDENTITY}" --preserve-metadata=identifier --entitlements "Payload/${PROJECT_NAME}.app/archived-expanded-entitlements.xcent" Payload/${PROJECT_NAME}.app
/usr/bin/zip -qr $IPA_FILE Payload

if [ $? == 0 ]; then
IPA_SIGNED_DIR="`dirname $IPA_FILE`"
mv $IPA_SIGNED_DIR $SIGNED_IPA_STORAGE_DIR/
echo "Package $MIN_PKG_NO successfully!"
fi

echo "$seq" 1>&9
}&
let MIN_PKG_NO=MIN_PKG_NO+1
done

wait

echo "successfully package"

exec 9>&-


