//
//  CCQueue.h
//  TestUT
//
//  Created by cocoa on 2018/12/19.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//队列FIFO，先进先出
@interface CCQueue : NSObject
/**
    当前队列数据
 */
@property(nonatomic,strong)NSArray *queueDB;

/**
    初始化一个队列，指定队列里元素个数
 */
+ (instancetype)shareWithCount:(int )qCount;

//销毁
+ (void)destory;

/**
    压入队列数据，当队列数据达到指定个数，将从队列顶移出先压入的数据；
 */
- (void)push:(id)obj;

/**
    从队列顶，移出一个数据，
 */
- (void)pop;

/**
    清空队列数据
 */
- (void)clear;


@end

NS_ASSUME_NONNULL_END
