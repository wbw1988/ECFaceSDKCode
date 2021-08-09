//
//  ECXMLConfig.h
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/16.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 XML 配置工具，用于当活检的参数是从服务器下发的XML时，用此工具解析并传入SDK
 */
@interface ECXMLConfig : NSObject

/**
    用XML参数初始化人脸识别sdk，
 
    示例：如下
    <param><actionList>1278</actionList><actionOrder>1*</actionOrder><shakeDegree>20</shakeDegree><imgCompress>85</imgCompress><pupilDistMin>80</pupilDistMin><pupilDistMax>170</pupilDistMax><timeOut>15</timeOut><isAudio>1</isAudio><eyeDegree>8</eyeDegree><mouthDegree>8</mouthDegree><rawDegree>5</rawDegree><pitchDegree>4</pitchDegree><isLog>1</isLog><deviceIdx>0</deviceIdx></param>
 
 */
+ (void)confFaceSDKFromXMLString:(NSString *)xmlStr;


@end

NS_ASSUME_NONNULL_END
