//
//  ECFaceDetecter.h
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/28.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


typedef enum : int {
    ECDetectErrorDuckDatNotExist = 1000,//算法库模型文件不存在
    ECDetectErrorDuckLicNotExist ,//授权文件不存在
    ECDetectErrorDuckExpiration ,//时间版本授权过期
    ECDetectErrorDuckNotMatch ,//包名绑定不一致
    ECDetectErrorDuckInitOther ,//算法初始化失败
    ECDetectErrorLiveCheckCancel,//检活取消了，
    ECDetectErrorTimeOutNoFace,//超时，未检测到人脸；
    ECDetectErrorTimeOutNoPass,//超时，动作未通过；
    ECDetectErrorCurrentFaceLost,//丢帧检测，在检活过程之中人脸离开换人；
    ECDetectErrorNotLiveFace,//检测到非活体


} ECDetectError;

typedef enum : int {
    ECLiveStateFaceNormal=0,//人脸数据正常检测
    ECLiveStateFaceLeave,//人脸离开
    ECLiveStateFaceShake,//人脸在晃动
    ECLiveStateFaceFar,//人脸离摄像头太远
    ECLiveStateFaceClose,//人脸离摄像头太近
    ECLiveStateNotLookCamera,//未直视摄像头
    ECLiveStateFaceHasCover,//检测到面部有遮挡
    //ECLiveStateFaceDefinitionLow,//人脸清晰低，可能光线不足，暂不可用
    ECLiveStateFaceHackNoPass,//检测到面部有遮挡
} ECLiveState;


typedef enum : int {
    ECLiveEYE = 1,//眨眼检测
    ECLiveMOU = 2,//张嘴检测
    ECLiveYAW = 7,//左右转头检测
    ECLiveNOD = 8,//上下点头检测
    ECLiveLOOK = 9//直视摄像头检测
} ECLiveType;
 


/**
    检测过程代理
 */
@protocol ECFaceDetecterDelegate <NSObject>



//成功回调
- (void)ECFaceLiveCheckSuccessGetImage:(NSArray *)imgArr;

//失败错误回调
- (void)ECFaceDetecterWithError:(ECDetectError )aErr liveType:(ECLiveType)alive;

//检测某个动作的倒计时，还剩下多长时间时间,单位秒
- (void)ECFaceCheckOneLive:(ECLiveType )alive leftTime:(int)leftTime;

//将要开始进行某个动作检活
- (void)ECFaceLiveWillStartCheck:(ECLiveType )alive;

//结束某个动作检活
- (void)ECFaceLiveDidCompleteCheck:(ECLiveType )alive;

//检活过程中状态回调
- (void)ECFaceLiveState:(ECLiveState)liveState liveType:(ECLiveType)alive;

//检活动作组合
- (NSArray *)ECFaceLiveCheckSequence;

//检活单个动作的超时时间
- (int)ECFaceLiveOneActionTime;

@end



/**
    活体检测封装
 */
@interface ECFaceDetecter : NSObject

@property (nonatomic,assign)id delegate;

@property (nonatomic,assign)UIDeviceOrientation orientation;

//版本信息以及sdk的一些信息
+ (NSDictionary *)sdkInfo;


//初始化算法
- (instancetype)initWithDat:(NSString *)datPath
                    license:(NSString *)licPath
                   imgWidth:(int )width
                  imgHeight:(int )height;

// 
- (void)stopEngin;

//开始进行活体检测
- (void)startLiveDetect;

//结束进行活体检测
- (void)stopLiveDetect;

//压入视频流
- (void)pushDetectBuffer:(CMSampleBufferRef )sampleBuffer
             orientation:(UIDeviceOrientation)orientation;


@end

NS_ASSUME_NONNULL_END
