//
//  ECFaceInfo.m
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/27.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import "ECFaceInfo.h"

@implementation ECFaceInfo

- (NSString *)description
{
    return [NSString stringWithFormat:@"ECFaceInfo: 照片=%@, 置信度=%d, 清晰度=%d, 眼睛张开度=%d, 嘴巴张开度=%d, 左右转头度=%d, 抬低头度=%d, 左右歪头度=%d, 双眼间距离=%d, 坐标(x=%d,y=%d,w=%d,h=%d) hack=%d",_curImage,_td_scor,_td_shrp,_td_eyed,_td_motd,_td_yaw,_td_pitch,_td_roll,_td_2eye_d,_td_rectX,_td_rectY,_td_rectW,_td_rectH,_hackScore];
}

- (void)dealloc
{
    _curImage = nil;
}

@end
