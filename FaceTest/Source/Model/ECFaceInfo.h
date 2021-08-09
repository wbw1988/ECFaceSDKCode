//
//  ECFaceInfo.h
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/27.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ECFaceInfo : NSObject

@property (nonatomic,strong)UIImage *curImage;//当前照片

@property (nonatomic,assign)int td_scor;//人脸置信度；
@property (nonatomic,assign)int td_shrp;//清晰度；

@property (nonatomic,assign)int td_eyed;//眼睛张开度；
@property (nonatomic,assign)int td_motd;//嘴巴张开度；
@property (nonatomic,assign)int td_yaw;//左右扭头度
@property (nonatomic,assign)int td_pitch;//抬低头度；
@property (nonatomic,assign)int td_roll;//左右歪头度；

@property (nonatomic,assign)int td_2eye_d;//双眼之间的距离长度；

@property (nonatomic,assign)int td_rectX;//矩形位置X；
@property (nonatomic,assign)int td_rectY;//矩形位置Y；
@property (nonatomic,assign)int td_rectW;//矩形人脸长；
@property (nonatomic,assign)int td_rectH;//矩形人脸宽；

@property (nonatomic,assign)int hackScore;//矩形人脸宽；
@property (nonatomic,assign)int faceId;//faceId；


@end

NS_ASSUME_NONNULL_END
