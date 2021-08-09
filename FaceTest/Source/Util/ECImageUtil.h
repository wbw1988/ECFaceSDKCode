//
//  ECImageUtil.h
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/27.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ECImageUtil : NSObject

/**
    视频流取的sampleBuffer转argb格式的UIImage
 */
+ (UIImage *)argbImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
    argb格式的UIImage解码取arg数据；
 */
+ (NSData *)rgbDataFromArgbImage:(UIImage *)image;

/**
 * 图片旋转(系统方法)
*/
+ (UIImage *)image:(UIImage *)image
          rotation:(UIImageOrientation)orientation;


@end

NS_ASSUME_NONNULL_END
