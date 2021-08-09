//
//  ECLogUtil.m
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/15.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import "ECLogUtil.h"
#import "ECLiveConfig.h"

static ECLogUtil *share = nil;

@interface ECLogUtil ()

@property (nonatomic,strong)NSDateFormatter *dateFMT;
@property (nonatomic,strong)NSMutableString *logBox;

@end

@implementation ECLogUtil

+ (instancetype)share{
    if (!share) {
        share = [[ECLogUtil alloc]init];
        share.logBox = [[NSMutableString alloc]initWithCapacity:1];
        
        share.dateFMT = [[NSDateFormatter alloc]init];
        [share.dateFMT setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];

    }
    
    return share;
}

+ (void)addMsg:(NSString *)msg{
    if ([ECLiveConfig share].isLog !=1) {
        return;
    }
    
    [[ECLogUtil share].logBox appendString:[NSString stringWithFormat:@"%@->%@",[[ECLogUtil share].dateFMT stringFromDate:[NSDate date]],msg]];
    [[ECLogUtil share].logBox appendString:@"\n"];

}

+ (void)save{
    if ([ECLiveConfig share].isLog !=1) {
        return;
    }
    
    if ([ECLogUtil share].logBox.length <10) {
        return;
    }
    
    [[ECLogUtil share].logBox writeToFile:[ECLiveConfig share].logFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self destory];
    
}

+ (void)destory{
    [ECLogUtil share].logBox = nil;
    share = nil;
}

- (void)dealloc
{
    _logBox = nil;
    _dateFMT = nil;
}

@end
