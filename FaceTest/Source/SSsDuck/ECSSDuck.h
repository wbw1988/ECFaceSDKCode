//
//  ECSSDuck.h
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/27.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECFaceInfo.h"
#import "ECImageUtil.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : int {
    ECSSInitOK,//初始化成功
    ECSSDatNotExist,//算法模型文件不存在
    ECSSLicNotExist,//授权文件不存在
    ECSSExpiration,//时间版本过期
    ECSSNotMatch,//包名不匹配
    ECSSOther,//其他错误
} ECSSState;

/**
    算法库的封装，当前SsDuck1200
 */
@interface ECSSDuck : NSObject

//算法版本
+ (NSString *)version;

//初始化算法
- (ECSSState)initEnginWithDat:(NSString *)datPath
                 license:(NSString *)licPath
                  bindID:(NSString *)idStr
                imgWidth:(int )width
               imgHeight:(int )height;

//人脸检测
- (ECFaceInfo *)detectFaceWithFrame:(UIImage *)argbImg;

//眨眼检测
- (BOOL)detectBlinkWithFrame:(UIImage *)argbImg;

//hack检测
- (int)hackDetectWithFSPF:(UIImage *)argbImg;

//遮挡检测
- (BOOL)coverDetectWithFrame:(UIImage *)argbImg;



//卸载算法
- (BOOL)deinitEngin;

@end

NS_ASSUME_NONNULL_END
