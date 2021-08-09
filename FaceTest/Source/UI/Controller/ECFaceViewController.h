//
//  ECFaceViewController.h
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/13.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark 活检的一些枚举

//失败的，错误码枚举
typedef enum : int {
    ECLivenessErrorDuckDatNotExist = 1000 , //算法库模型文件不存在
    ECLivenessErrorDuckLicNotExist        , //授权文件不存在
    ECLivenessErrorDuckExpiration         , //时间版本授权过期
    ECLivenessErrorDuckNotMatch           , //包名绑定不一致
    ECLivenessErrorDuckInitOther          , //算法初始化失败
    ECLivenessErrorLiveCheckCancel        , //检活取消了，
    ECLivenessErrorTimeOutNoFace          , //超时，未检测到人脸；
    ECLivenessErrorTimeOutNoPass          , //超时，动作未通过；
    ECLivenessErrorCurrentFaceLost        , //丢帧检测，在检活过程之中人脸离开换人；
    ECLivenessErrorNotLiveFace            , //检测到非活体；
    ECLivenessErrorCameraNotAuth            //摄像头权限未授权，请用户授权；

} ECLivenessError;

//支持的，活检动作枚举
typedef enum : int {
    ECLivenessEYE = 1 , //眨眼检测
    ECLivenessMOU = 2 , //张嘴检测
    ECLivenessYAW = 7 , //左右转头检测
    ECLivenessNOD = 8   //上下点头检测
} ECLivenessType;

#pragma mark 活检的回调代理

/**
    活检控制器的回调，成功，失败
 */
@protocol ECFaceLivenessDelegate <NSObject>

@required

/**
    活体检测成功，
 imgArr: 成功采集的照片，每个动作采集一张；为UIImage数组
 liveArr: 检活过程之中做的动作；为ECLivenessType数组
 */
- (void)faceLivenessSuccessWithImg:(NSArray *)imgArr liveArr:(NSArray *)liveArr;

/**
    活体检测失败
 aErr: 当前失败的错误码
 aLive: 失败时当前正在进行检测的动作，用于分析超时和未通过的动作
 */
- (void)faceLivenessFailedWithError:(ECLivenessError )aErr liveType:(ECLivenessType )aLive;

@end

#pragma mark 活检测控制器

/**
    封装的活检控制器
 */
@interface ECFaceViewController : UIViewController
//代理
@property (nonatomic,assign)id<ECFaceLivenessDelegate>delegate;

/**
    SDK的详细信息，含版本号、授权等信息；
 */
+ (NSDictionary *)sdkInfo;

@end

NS_ASSUME_NONNULL_END
