//
//  CCQueue.m
//  TestUT
//
//  Created by cocoa on 2018/12/19.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import "CCQueue.h"

static CCQueue *shared = nil;

@interface CCQueue ()
@property(nonatomic,strong)NSMutableArray *queueBox;
@property(nonatomic,assign)int queueCount;
@end


@implementation CCQueue


+ (instancetype)shareWithCount:(int )qCount{
    if (!shared) {
        shared = [[CCQueue alloc]init];
        if (qCount<1 || qCount >50) {
            shared.queueBox = [[NSMutableArray alloc]initWithCapacity:10];
            shared.queueCount = 10;
        }else{
            shared.queueBox = [[NSMutableArray alloc]initWithCapacity:qCount];
            shared.queueCount = qCount;
        }
    }
    return shared;
    
}


- (void)push:(id)obj{
    if (self.queueBox.count>=self.queueCount) {
        [self.queueBox removeObjectAtIndex:0];
    }
    [self.queueBox addObject:obj];
}

- (void)pop{
    if (self.queueBox.count>0) {
        [self.queueBox removeObjectAtIndex:0];
    }
}

- (void)clear{
    if (self.queueBox.count>0) {
        [self.queueBox removeAllObjects];
    }
}

- (NSArray *)queueDB{
    return [NSArray arrayWithArray:self.queueBox];
}

+ (void)destory{
    shared = nil;
}

- (void)dealloc
{
    _queueBox = nil;
    _queueDB = nil;
    //NSLog(@"CCQueue dealloc");
}

@end
