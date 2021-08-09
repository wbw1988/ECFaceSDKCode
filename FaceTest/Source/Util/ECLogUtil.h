//
//  ECLogUtil.h
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/15.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
    日志工具，保存日志到文件
 */
@interface ECLogUtil : NSObject

+ (void)addMsg:(NSString *)msg;

+ (void)save;

+ (void)destory;


@end

NS_ASSUME_NONNULL_END
