//
//  ECAudioPlayer.m
//  EyeCoolFace
//
//  Created by cocoa on 2018/10/10.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import "ECAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "ECLiveConfig.h"

static ECAudioPlayer *share = nil;

@interface ECAudioPlayer ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
}

@end

@implementation ECAudioPlayer

+ (instancetype)share{
    
    if (!share) {
        share = [[ECAudioPlayer alloc] init];
        share.bOn = YES;
    }
    return share;
}

/**
 播放声音
 */
- (void)playAudio:(ECAudioType )audio{
    
    if (self.bOn==NO) {
        return;
    }
    
    NSString *audioName;
    switch (audio) {
        case ECAudioBlinkEyes:
            audioName = kECAUDIO_BLINK;
            break;
        case ECAudioOpenMouth:
            audioName = kECAUDIO_MOUTH;
            break;
        case ECAudioYawHead:
            audioName = kECAUDIO_YAW;
            break;
        case ECAudioNodHead:
            audioName = kECAUDIO_NOD;
            break;
        case ECAudioGood:
            audioName = kECAUDIO_Good;
            break;
        case ECAudioClosely:
            audioName = kECAUDIO_Close;
            break;
        case ECAudioFarAway:
            audioName = kECAUDIO_Far;
            break;
        default:
            audioName = nil;
            break;
    }
    
    if (!audioName) {
        return;
    }
    
    NSBundle *sdkBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[ECLiveConfig share].sdkBundleName ofType:nil]];
    NSString *wavPath = [sdkBundle pathForResource:audioName ofType:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]==NO) {
        return;
    }
    
    [self forceStop];
    
    NSError *audioError;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:wavPath] error:&audioError];
    if (audioError) {
        return ;
    }
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
}


/**
 强制结束语音播放
 */
- (void)forceStop{
    if (audioPlayer) {
        if (audioPlayer.isPlaying) {
            [audioPlayer stop];
        }
        audioPlayer = nil;
    }
}

+ (void)destory{
    share = nil;
}

- (void)dealloc
{
    audioPlayer = nil;
    //NSLog(@"audioPlayer dealloc");
}

@end
