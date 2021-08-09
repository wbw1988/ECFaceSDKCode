#!/bin/sh
#
# iOS自动编译静态库脚本，编译模拟器+真机版，并自动合并成一个.a
# 1. 首先在xcode配置完要编译的架构和最低支持iOS SDK版本；
# 2. 在下方TODO处修改你要生成的库的名称
# guojianheng@eyecool.cn
# 3. 将此脚本和.xcxx xcode工程文件放在同一目录执行即可；
# 4. 在桌面将会生成你需要的库,并将其他需要的文件一起打包成SDK包
#

# ----- 编译SDK部分 ------

#要build的target名
#TODO: 如下变量修改为你要编译生成的库的名称
tgName="ECFaceSDK"

osa="lib"$tgName"_iphoneos.a"
sima="lib"$tgName"_iphonesimulator.a"
suma="lib"$tgName".a"

#如果存在删除当前已经编译的库
if [ -f $osa ];then
rm -rf $osa
fi

if [ -f $sima ];then
rm -rf $sima
fi

if [ -f $suma ];then
rm -rf $suma
fi

#build os
xcodebuild clean
xcodebuild -target $tgName -configuration Release -sdk iphoneos
mv build/Release-iphoneos/"lib"$tgName".a" ./$osa

#build sim
xcodebuild clean
xcodebuild -target $tgName -configuration Release -sdk iphonesimulator
mv build/Release-iphonesimulator/"lib"$tgName".a" ./$sima

xcodebuild clean

#合并SDK(sim+os)
lipo -create ./$osa ./$sima -output ./$suma

# ----- 创建SDK目录部分 ------

# 创建桌面的文件夹ECFaceSDK
filePath=~/Desktop/ECFaceSDK
# 判断ECFaceSDK文件夹是否存在
if [ ! -d $filePath ];then
mkdir $filePath
echo "创建ECFaceSDK文件夹成功"
else
echo "文件夹已经存在"
# 删除存在的~/Desktop/ECFaceSDK,新建
rm -rf $filePath
mkdir $filePath
fi

# ----- 移动SDK部分 -----
# 将SDK移动到~/Desktop/ECFaceSDK
mv $suma $filePath
# 将bundle复制到~/Desktop/ECFaceSDK
cp -R ./FaceTest/Source/Bundle/ECFaceSDK.bundle $filePath

# 创建include
includePath=$filePath/include
#echo "includePath:${includePath}"
mkdir $includePath
echo "创建/include文件夹成功"

# 创建UI文件夹
uiPath=$includePath/UI
mkdir $uiPath
cp -R ./FaceTest/Source/UI/ $uiPath

# 创建config文件夹
configPath=$includePath/config
mkdir $configPath
cp -R ./FaceTest/Source/Config/ $configPath

# 创建model文件夹
modelPath=$includePath/model
mkdir $modelPath
cp -R ./FaceTest/Source/Model/ $modelPath

# 创建util文件夹
utilPath=$includePath/util
mkdir $utilPath
cp ./FaceTest/Source/Util/ECImageUtil.h $utilPath
cp ./FaceTest/Source/Manager/ECFaceDetecter.h $utilPath
cp ./FaceTest/Source/Manager/ECAudioPlayer.* $utilPath
cp ./FaceTest/Source/Manager/ECCameraManager.h $utilPath

# 如果不需要单独的模拟器文件和真文件可以删除
rm -rf $osa
rm -rf $sima

echo "------------------------------------"
echo ""
echo "building success."
echo ""
lipo -info ~/Desktop/$suma
echo ""
echo "------------------------------------"
