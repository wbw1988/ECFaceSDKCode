//
//  ECLiveConfig.h
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/11.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//支持的，活检屏幕横竖屏状态
typedef enum : int {
    ECLiveOrientationPortrait = 0, // 支持竖直 竖屏
    ECLiveOrientationLeft     = 1, // 支持左转 横屏
    ECLiveOrientationRight    = 2, // 支持右转 横屏
    ECLiveOrientationRotation = 3  // 支持旋转 默认竖屏
} ECLiveOrientationType;


/**
    参数配置
 */
@interface ECLiveConfig : NSObject

//单例，请使用单例，勿要alloc
+ (instancetype)share;

//回收
+ (void)destory;

#pragma mark 以下为 检活过程之中的一些参数阈值配置

//动作配置,如果不配置此参数，将启用内部随机，随机的个数由[ECLiveConfig share].action决定；
//如果配置此参数，那么将以配置的动作为准，示例 liveTypeArr = @[@(ECLivenessMOU),@(ECLivenessMOU)]
@property (nonatomic,strong)NSArray *liveTypeArr;

@property (nonatomic,assign)int imgCompress;    //苹果JPEG压缩比 1~100
@property (nonatomic,assign)int pupilDistMin;   //人脸距离屏幕的最小距离
@property (nonatomic,assign)int pupilDistMax;   //人脸距离屏幕的最大距离
@property (nonatomic,assign)int timeOut;        //单个动作的超时时间
@property (nonatomic,assign)int isAudio;        //是播放声音提示
@property (nonatomic,assign)int definitionAsk;  //清晰度检测阈值
@property (nonatomic,assign)int deviceIdx;  //摄像头，0前置，1后置
@property (nonatomic,assign)int action;         //活检测动作个数
@property (nonatomic,assign)int headLeft;       //人脸头部左转的阈值
@property (nonatomic,assign)int headRight;      //人脸头右转的阈值
@property (nonatomic,assign)int headLow;        //低头的阈值
@property (nonatomic,assign)int headHigh;       //抬头的阈值
@property (nonatomic,assign)int eyeDegree;      //眼镜睁开度的阈值
@property (nonatomic,assign)int mouthDegree;    //嘴巴张开度的阈值
@property (nonatomic,assign)int isLog;          //是生成日志文件
@property (nonatomic,strong)NSString *logFile;  //保存日志的路径及名字，一般在app的Document目录下

@property (nonatomic,assign)int rollLeft;       //左歪头值
@property (nonatomic,assign)int rollRight;       //右歪头阈值
@property (nonatomic,assign)int mouThres;    //张嘴动作值
@property (nonatomic,assign)int yawThres;    //转头动作值
@property (nonatomic,assign)int pitThres;    //点头动作值
@property (nonatomic,assign)int eyeThres;    //眨眼动作值


@property (nonatomic,assign)int shakeMax;       //晃动检测阈值；
@property (nonatomic,assign)int queueMax;       //晃动检测缓冲数据帧数；
@property (nonatomic,assign)BOOL lostDetect;     //是否启用丢帧检测；
@property (nonatomic,assign)int lostCount;       //丢帧检测误差帧数；
@property (nonatomic,assign)BOOL onlyFocus;      //仅有直视摄像头；

// 告知ECFaceViewController支持的横竖屏方式
@property (nonatomic,assign)ECLiveOrientationType liveOrientation;


#pragma mark 以下为 检活过程之中的文字信息配置

@property (nonatomic,strong)NSString *willStartMsg;     //即将开始识别
@property (nonatomic,strong)NSString *pleaseFaceIn;     //请将人脸移入框内
@property (nonatomic,strong)NSString *pleaseNoShake;    //请不要晃动
@property (nonatomic,strong)NSString *pleaseClosely;    //请向前靠近一点
@property (nonatomic,strong)NSString *pleaseFarAwy;     //请向后远离一点
@property (nonatomic,strong)NSString *pleaseBlinkEyes;  //请眨眨眼
@property (nonatomic,strong)NSString *pleaseOpenMouth;  //请张张嘴
@property (nonatomic,strong)NSString *pleaseTurnHead;   //请转转头
@property (nonatomic,strong)NSString *pleaseNodHead;    //请上下转头
@property (nonatomic,strong)NSString *pleaseLookCamera;    //请直视摄像头
@property (nonatomic,strong)NSString *pleaseFocusCamera;    //请正面望向镜头
@property (nonatomic,strong)NSString *pleaseNotCoverFace;   //请不要遮挡人脸


//当你需要把sdk的资源文件统一放到你的sdk bundle中时，可以修改下面，修改sdk读取资源的bundle文件名
@property (nonatomic,strong)NSString *sdkBundleName;    //当前为ECFaceSDK.bundle



@end

NS_ASSUME_NONNULL_END
