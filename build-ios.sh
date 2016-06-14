#!/bin/bash

PLATFORMPATH="/Applications/Xcode.app/Contents/Developer/Platforms"
TOOLSPATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
export IPHONEOS_DEPLOYMENT_TARGET="8.0"
pwd=`pwd`

findLatestSDKVersion()
{
    sdks=`ls $PLATFORMPATH/$1.platform/Developer/SDKs`
    arr=()
    for sdk in $sdks
    do
	arr[${#arr[@]}]=$sdk
    done

    # Last item will be the current SDK, since it is alpha ordered
    count=${#arr[@]}
    if [ $count -gt 0 ]; then
	sdk=${arr[$count-1]:${#1}}
	num=`expr ${#sdk}-4`
	SDKVERSION=${sdk:0:$num}
    else
	SDKVERSION="8.0"
    fi
}

buildit()
{
    target=$1
    hosttarget=$1
    platform=$2

    if [[ $hosttarget == "x86_64" ]]; then
	hostarget="i386"
    elif [[ $hosttarget == "arm64" ]]; then
	hosttarget="arm"
    fi

    export CC="$(xcrun -sdk iphoneos -find clang)"
    export CPP="$CC -E"
    export CFLAGS="-arch ${target} -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk -miphoneos-version-min=$SDKVERSION"
    export AR=$(xcrun -sdk iphoneos -find ar)
    export RANLIB=$(xcrun -sdk iphoneos -find ranlib)
    export CPPFLAGS="-arch ${target}  -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk -miphoneos-version-min=$SDKVERSION"
    export LDFLAGS="-arch ${target} -isysroot $PLATFORMPATH/$platform.platform/Developer/SDKs/$platform$SDKVERSION.sdk"

    mkdir -p $pwd/output/$target

    ./configure --prefix="$pwd/output/$target" --disable-server --disable-client --enable-ios-controller --host=$hosttarget-apple-darwin
    
    make clean
    make
    # TODO: Add this to the make install or something
    cp "$pwd/src/crypto/libmoshcrypto.a" "$pwd/output/$target"
    cp "$pwd/src/network/libmoshnetwork.a" "$pwd/output/$target"
    cp "$pwd/src/protobufs/libmoshprotos.a" "$pwd/output/$target"
    cp "$pwd/src/statesync/libmoshstatesync.a" "$pwd/output/$target"
    cp "$pwd/src/terminal/libmoshterminal.a" "$pwd/output/$target"
    cp "$pwd/src/frontend/libmoshios.a" "$pwd/output/$target"
    cp "$pwd/src/util/libmoshutil.a" "$pwd/output/$target"
    # needs a fix to install the library in the right path
    #make install 
}

findLatestSDKVersion iPhoneOS

buildit armv7 iPhoneOS
buildit armv7s iPhoneOS
buildit arm64 iPhoneOS
buildit i386 iPhoneSimulator
buildit x86_64 iPhoneSimulator

LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshcrypto.a $pwd/output/i386/libmoshcrypto.a $pwd/output/armv7/libmoshcrypto.a $pwd/output/armv7s/libmoshcrypto.a $pwd/output/arm64/libmoshcrypto.a  -output $pwd/output/libmoshcrypto.a
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshnetwork.a $pwd/output/i386/libmoshnetwork.a -output $pwd/output/libmoshnetwork.a $pwd/output/armv7/libmoshnetwork.a $pwd/output/armv7s/libmoshnetwork.a $pwd/output/arm64/libmoshnetwork.a 
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshprotos.a $pwd/output/i386/libmoshprotos.a -output $pwd/output/libmoshprotos.a $pwd/output/armv7/libmoshprotos.a $pwd/output/armv7s/libmoshprotos.a $pwd/output/arm64/libmoshprotos.a 
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshios.a $pwd/output/i386/libmoshios.a -output $pwd/output/libmoshios.a $pwd/output/armv7/libmoshios.a $pwd/output/armv7s/libmoshios.a $pwd/output/arm64/libmoshios.a 
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshstatesync.a $pwd/output/i386/libmoshstatesync.a -output $pwd/output/libmoshstatesync.a $pwd/output/armv7/libmoshstatesync.a $pwd/output/armv7s/libmoshstatesync.a $pwd/output/arm64/libmoshstatesync.a 
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshterminal.a $pwd/output/i386/libmoshterminal.a -output $pwd/output/libmoshterminal.a $pwd/output/armv7/libmoshterminal.a $pwd/output/armv7s/libmoshterminal.a $pwd/output/arm64/libmoshterminal.a 
LIPO=$(xcrun -sdk iphoneos -find lipo)
$LIPO -create $pwd/output/x86_64/libmoshutil.a $pwd/output/i386/libmoshutil.a -output $pwd/output/libmoshutil.a $pwd/output/armv7/libmoshutil.a $pwd/output/armv7s/libmoshutil.a $pwd/output/arm64/libmoshutil.a 
