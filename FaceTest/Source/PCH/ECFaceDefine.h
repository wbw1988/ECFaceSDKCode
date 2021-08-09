//
//  ECFaceDefine.h
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/13.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#ifndef ECFaceDefine_h
#define ECFaceDefine_h


//是否输出当前帧的检测耗时及当前帧信息
#define EC_EN_LOG_BUFFER_TIME 0
//是否输出算法的一些信息
#define EC_EN_LOG_SSALG_INFO 0
//是否输出检活过程之中的值
#define EC_EN_LOG_LIVE_INFO 0


//版本
#define EC_SDK_VERSION @"4.4.6.V"
//算法版
#define EC_SS_ALG_VER @"1.4.8.5"
//build打包时间
#define EC_SDK_BUILD @"2020-12-24d"

//版本描述信息
#define EC_SDK_INFO @"license in EyeCoolLive.lic"


//判断是iPhone5
#define EC_IS_PHONE5Serai ([UIScreen instancesRespondToSelector:@selector(currentMode)]\
? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)\
|| CGSizeEqualToSize(CGSizeMake(1136, 640), [[UIScreen mainScreen] currentMode].size) : NO)


#endif /* ECFaceDefine_h */
