//
//  ZJLivePolicy.h
//  ECFaceSDK
//
//  Created by cocoa on 2020/1/7.
//  Copyright © 2020 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJLivePolicy : NSObject

+ (void)reset;

+ (BOOL)detectLive:(int)nMove threshold:(int )nThreshold cur:(int )nCur;

@end

NS_ASSUME_NONNULL_END
