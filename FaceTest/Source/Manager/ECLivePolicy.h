//
//  ECLivePolicy.h
//  EyeCoolFace
//
//  Created by cocoa on 2018/10/8.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECFaceInfo.h"
#import "ECFaceDetecter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 人脸晃动检测的坐标
 */
typedef enum : int {
    ECShakeFaceX=0,//检测坐标X
    ECShakeFaceY,//检测坐标Y
    ECShakeFaceXY,//检测坐标X,Y
} ECShakeType;

/**
    检活策略
 */

@interface ECLivePolicy : NSObject


//直视摄像头
+ (BOOL)liveCheckLookCameraWith:(ECFaceInfo *)theFace;

//直视正脸挑图
+ (BOOL)liveChooseJustFaceImage:(ECFaceInfo *)face;

//检测人脸太远
+ (BOOL)liveCheckFaceFarWith:(ECFaceInfo *)theFace;

//检测人脸太近
+ (BOOL)liveCheckFaceCloseWith:(ECFaceInfo *)theFace;

//检测人脸晃动
+ (BOOL)liveCheckFaceShakeWith:(ECFaceInfo *)theFace shakeType:(ECShakeType )tp;
+ (BOOL)liveCheckFaceShakeNewWith:(ECFaceInfo *)theFace shakeType:(ECShakeType )tp;


//挑图策略
+ (BOOL)liveChooseBetterImageWith:(ECFaceInfo *)theFace
                         lastFace:(ECFaceInfo *)lastFace
                         liveType:(ECLiveType )liveTp;

@end

NS_ASSUME_NONNULL_END
