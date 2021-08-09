//
//  ECAudioPlayer.h
//  EyeCoolFace
//
//  Created by cocoa on 2018/10/10.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//语音文件名
#define kECAUDIO_BLINK @"ecaudio_blink.wav"
#define kECAUDIO_MOUTH @"ecaudio_mouth.wav"
#define kECAUDIO_YAW @"ecaudio_yaw.wav"
#define kECAUDIO_NOD @"ecaudio_nod.wav"
#define kECAUDIO_Good @"ecaudio_good.wav"
#define kECAUDIO_Close @"ecaudio_close.wav"
#define kECAUDIO_Far  @"ecaudio_far.wav"


//检活过过程之中的语音提示
typedef enum : int {
    ECAudioBlinkEyes,   //请眨眨眼
    ECAudioOpenMouth,   //请张张嘴
    ECAudioYawHead,     //请转转头
    ECAudioNodHead,     //请上下点头
    ECAudioGood,        //很好
    ECAudioClosely,     //请向前靠近一点
    ECAudioFarAway,     //请向后远离一点
}ECAudioType;


/**
    声音播放器
 */
@interface ECAudioPlayer : NSObject

@property (nonatomic,assign)BOOL bOn;

+ (instancetype)share;

+ (void)destory;


/**
    播放声音
 */
- (void)playAudio:(ECAudioType )audio;


/**
    强制结束语音播放
 */
- (void)forceStop;

@end

NS_ASSUME_NONNULL_END
