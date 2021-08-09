//
//  ECLivePolicy.m
//  EyeCoolFace
//
//  Created by cocoa on 2018/10/8.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import "ECLivePolicy.h"
#import "ECLiveConfig.h"
#import "CCQueue.h"
#import "ECFaceDefine.h"
#import "ECLogUtil.h"


//#if !EC_EN_LOG_LIVE_INFO
//#define NSLog(...) 
//#endif

@implementation ECLivePolicy


//直视摄像头
+ (BOOL)liveCheckLookCameraWith:(ECFaceInfo *)theFace{
    
    //NSLog(@"直视：%d",theFace.td_motd);
    [ECLogUtil addMsg:[NSString stringWithFormat:@"直视检测"]];
    if ([self liveChooseJustFaceImage:theFace]) {
        //NSLog(@"直视过：%d",theFace.td_motd);
        [ECLogUtil addMsg:[NSString stringWithFormat:@"直视过---------------"]];
        return YES;
    }
    
    return NO;
}

+ (BOOL)liveChooseJustFaceImage:(ECFaceInfo *)face{
    
    BOOL fdJudge = NO;
    
    
    
    if ((face.td_yaw >= [ECLiveConfig share].headLeft) &&
        (face.td_yaw <= [ECLiveConfig share].headRight) &&
        (face.td_pitch >= [ECLiveConfig share].headHigh) &&
        (face.td_pitch <= [ECLiveConfig share].headLow) &&
        (face.td_roll >= [ECLiveConfig share].rollRight) &&
        (face.td_roll <= [ECLiveConfig share].rollLeft) &&
        (face.td_eyed >= [ECLiveConfig share].eyeDegree) &&
        (face.td_motd <= [ECLiveConfig share].mouthDegree)
        ) {
        fdJudge = YES;
    }
    
    //NSLog(@"返回的正脸检测结果:%ld\nface.td_yaw : %d >= [ECLiveConfig share].headLeft : %d \nface.td_yaw : %d <= [ECLiveConfig share].headRight : %d \nface.td_pitch : %d >= [ECLiveConfig share].headHigh : %d \nface.td_pitch : %d <= [ECLiveConfig share].headLow : %d \nface.td_roll : %d >= [ECLiveConfig share].rollRight : %d \nface.td_roll : %d <= [ECLiveConfig share].rollLeft : %d \nface.td_eyed : %d >= [ECLiveConfig share].eyeDegree : %d \nface.td_motd : %d <= [ECLiveConfig share].mouthDegree : %d \n",(long)fdJudge,face.td_yaw,[ECLiveConfig share].headLeft,face.td_yaw,[ECLiveConfig share].headRight,face.td_pitch,[ECLiveConfig share].headHigh,face.td_pitch,[ECLiveConfig share].headLow,face.td_roll,[ECLiveConfig share].rollRight,face.td_roll,[ECLiveConfig share].rollLeft,face.td_eyed,[ECLiveConfig share].eyeDegree,face.td_motd,[ECLiveConfig share].mouthDegree);
     
    return fdJudge;
}


//检测人脸太远
+ (BOOL)liveCheckFaceFarWith:(ECFaceInfo *)theFace{
    
    if (theFace.td_2eye_d < [ECLiveConfig share].pupilDistMin) {
        NSLog(@"检测到：离的太远了：%d",theFace.td_2eye_d);
        return YES;
    }
    
    return NO;
}

//检测人脸太近
+ (BOOL)liveCheckFaceCloseWith:(ECFaceInfo *)theFace{
    
    if (theFace.td_2eye_d > [ECLiveConfig share].pupilDistMax) {
        //NSLog(@"检测到：离的太近了：%d",theFace.td_2eye_d);
        return YES;
    }
    
    return NO;
    
}

//检测人脸晃动
+ (BOOL)liveCheckFaceShakeWith:(ECFaceInfo *)theFace shakeType:(ECShakeType )tp;
{
    int queueMax = [ECLiveConfig share].queueMax;
    CCQueue *queue = [CCQueue shareWithCount:queueMax];
    [queue push:@[@(theFace.td_rectX),@(theFace.td_rectY)]];
    if (queue.queueDB.count == queueMax) {
        double xVari = 0;
        double yVari = 0;
        if (tp == ECShakeFaceX){
            xVari = [self calVarianceX:queue.queueDB];
        }else if (tp == ECShakeFaceY){
            yVari = [self calVarianceY:queue.queueDB];
        }else{
            xVari = [self calVarianceX:queue.queueDB];
            yVari = [self calVarianceY:queue.queueDB];
        }
        
        //NSLog(@"xVari: %.0f yVari: %.0f",xVari,yVari);
        if (xVari >= [ECLiveConfig share].shakeMax || yVari >= [ECLiveConfig share].shakeMax) {
            //检测到晃动
            //NSLog(@"检测到晃动：xVari: %.0f yVari: %.0f",xVari,yVari);
            [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸晃动，xVari: %.0f, yVari: %.0f",xVari,yVari]];
            return YES;
        }
    }
    return NO;
}

//检测人脸晃动
+ (BOOL)liveCheckFaceShakeNewWith:(ECFaceInfo *)theFace shakeType:(ECShakeType )tp;
{
    BOOL shake = YES;
    int queueMax = [ECLiveConfig share].queueMax;
    CCQueue *queue = [CCQueue shareWithCount:queueMax];
    [queue push:@[@(theFace.td_rectX),@(theFace.td_rectY)]];
    if (queue.queueDB.count == queueMax) {
        double xVari = 0;
        double yVari = 0;
        if (tp == ECShakeFaceX){
            xVari = [self calVarianceX:queue.queueDB];
            if (xVari < [ECLiveConfig share].shakeMax) {
                shake = NO;
            }
        }else if (tp == ECShakeFaceY){
            yVari = [self calVarianceY:queue.queueDB];
            if (yVari < [ECLiveConfig share].shakeMax) {
                shake = NO;
            }
        }else{
            xVari = [self calVarianceX:queue.queueDB];
            yVari = [self calVarianceY:queue.queueDB];
            if (xVari < [ECLiveConfig share].shakeMax && yVari < [ECLiveConfig share].shakeMax) {
                shake = NO;
            }
        }
        
        if (shake) {
            //检测到晃动
            //NSLog(@"检测到晃动：xVari: %.0f yVari: %.0f",xVari,yVari);
            [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸晃动，xVari: %.0f, yVari: %.0f",xVari,yVari]];
        }
 
    }
    return shake;
}




//晃动方差计算X
+ (double)calVarianceX:(NSArray *)queueDB{
    double variance = 0;//方差
    double sum = 0, sum2 = 0;
    int len = (int)queueDB.count;
    for (NSArray *oneArr in queueDB) {
        NSNumber *oneNum = [oneArr objectAtIndex:0];
        sum += oneNum.intValue;
        sum2 += oneNum.intValue * oneNum.intValue;
    }
    variance = sum2 / len - (sum / len) * (sum / len);
    return variance;
}

//晃动方差计算Y
+ (double)calVarianceY:(NSArray *)queueDB{
    double variance = 0;//方差
    double sum = 0, sum2 = 0;
    int len = (int)queueDB.count;
    for (NSArray *oneArr in queueDB) {
        NSNumber *oneNum = [oneArr objectAtIndex:1];
        sum += oneNum.intValue;
        sum2 += oneNum.intValue * oneNum.intValue;
    }
    variance = sum2 / len - (sum / len) * (sum / len);
    return variance;
}



//挑图策略
+ (BOOL)liveChooseBetterImageWith:(ECFaceInfo *)theFace
                         lastFace:(ECFaceInfo *)lastFace
                         liveType:(ECLiveType )liveTp
{
    if (lastFace == nil) {
        return NO;
    }
    
    
    BOOL judgeBetter = NO;
    
    switch (liveTp) {
        case ECLiveEYE:
        {
            if (theFace.td_eyed>=[ECLiveConfig share].eyeDegree &&
                (theFace.td_eyed > lastFace.td_eyed) ) {
                judgeBetter = YES;
            }
            break;
        }
        case ECLiveMOU:
        {
            if (theFace.td_eyed>=[ECLiveConfig share].eyeDegree &&
                (theFace.td_motd < lastFace.td_motd)) {
                judgeBetter = YES;
            }
            break;
        }
        case ECLiveYAW:
        {
            if (theFace.td_motd<=[ECLiveConfig share].mouthDegree &&
                theFace.td_eyed>=[ECLiveConfig share].eyeDegree &&
                (abs(theFace.td_yaw) < abs([ECLiveConfig share].headLeft)) ) {
                judgeBetter = YES;
            }
            break;
        }
        case ECLiveNOD:
        {
            if (theFace.td_motd<=[ECLiveConfig share].mouthDegree &&
                theFace.td_eyed>=[ECLiveConfig share].eyeDegree &&
                (abs(theFace.td_pitch) < abs([ECLiveConfig share].headHigh)) ) {
                judgeBetter = YES;
            }
            break;
        }
            /*
        case ECLiveLOOK:
        {
            if ((theFace.td_yaw >= [ECLiveConfig share].headLeft) &&
                (theFace.td_yaw <= [ECLiveConfig share].headRight) &&
                (theFace.td_pitch >= [ECLiveConfig share].headHigh) &&
                (theFace.td_pitch <= [ECLiveConfig share].headLow) &&
                (theFace.td_roll >= [ECLiveConfig share].rollRight) &&
                (theFace.td_roll <= [ECLiveConfig share].rollLeft) &&
                (theFace.td_eyed >= [ECLiveConfig share].eyeDegree) &&
                (theFace.td_motd <= [ECLiveConfig share].mouthDegree) ) {
                judgeBetter = YES;
            }
            break;
        }
             */
        default:
            judgeBetter = YES;
            break;
    }
    
    if (judgeBetter) {
        //符合条件
        NSLog(@"挑图策略挑图中...");
        return YES;
    }
    
    return NO;
}

@end
