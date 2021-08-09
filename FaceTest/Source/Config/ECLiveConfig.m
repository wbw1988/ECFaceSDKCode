//
//  ECLiveConfig.m
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/11.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import "ECLiveConfig.h"

static ECLiveConfig *share = nil;

@implementation ECLiveConfig

+ (instancetype)share{
    
    if (!share) {
        
        share = [[ECLiveConfig alloc] init];
        //默认值
        share.imgCompress = 85;
        // 超时时间10秒
        share.timeOut = 10;
        share.isAudio = 1;
        share.definitionAsk = 20;
        share.action = 1;
        
        share.isLog = 1;
        share.deviceIdx = 0;
        share.shakeMax = 20;
        share.queueMax = 6;
        share.lostDetect = YES;
        share.lostCount = 8;
        
        
        share.pupilDistMin = 80;
        share.pupilDistMax = 170;
        
        share.headLeft = -10;
        share.headRight = 10;
        share.headLow = 5;
        share.headHigh = -12;
        share.rollLeft = 12;
        share.rollRight = -12;
        share.eyeDegree = 9;
        share.mouthDegree = 15;
        
        share.mouThres = 8;
        share.yawThres = 5;
        share.pitThres = 4;
        share.eyeThres = 8;
        
        share.lostDetect = YES;
        share.lostCount = 20;
        
        // 屏幕旋转的方式
        share.liveOrientation = ECLiveOrientationPortrait;
        
        share.willStartMsg = @"即将开始识别";
        share.pleaseFaceIn = @"请将人脸移入框内";
        share.pleaseNoShake = @"请不要晃动";    //请不要晃动
        share.pleaseClosely = @"请向前靠近一点";
        share.pleaseFarAwy = @"请向后远离一点";
        share.pleaseBlinkEyes = @"请眨眨眼";
        share.pleaseOpenMouth = @"请张张嘴";
        share.pleaseTurnHead = @"请转转头";
        share.pleaseNodHead = @"请上下点头";
        // 暂时去除请直视摄像头的提示和语音
        //share.pleaseLookCamera = @"请直视摄像头";
        share.pleaseFocusCamera = @"请正脸面对镜头";
        share.pleaseNotCoverFace = @"请不要遮挡正脸";
        
        share.sdkBundleName = @"ECFaceSDK.bundle";
        
        //日志文件路径
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
        NSString *faceLog = [NSString stringWithFormat:@"%@/ecface.log",documentPath];
        share.logFile = faceLog;

    }
    return share;
}


+ (void)destory{
    share = nil;
}



- (void)dealloc
{
    _pleaseFaceIn = nil;
    _pleaseClosely = nil;
    _pleaseFarAwy = nil;
    _pleaseBlinkEyes = nil;
    _pleaseOpenMouth = nil;
    _pleaseTurnHead = nil;
    _pleaseNodHead = nil;
    _willStartMsg = nil;
    _liveTypeArr = nil;
    _logFile = nil;
    _sdkBundleName = nil;
    //NSLog(@"ECLiveConfig dealloc");
}

@end
