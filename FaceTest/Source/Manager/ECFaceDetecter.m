//
//  ECFaceDetecter.m
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/28.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import "ECFaceDetecter.h"
#import "ECWeakProxy.h"
#import "ECLivePolicy.h"
#import "CCQueue.h"
#import "ECSSDuck.h"
#import "ECImageUtil.h"
#import "ECFaceDefine.h"
#import "ECLiveConfig.h"
#import "ECLogUtil.h"
#import "ZJLivePolicy.h"

@interface ECFaceDetecter ()
{
    NSString *ss_datPath;
    NSString *ss_licPath;
    NSString *ss_idStr;
    int ss_Width;
    int ss_Height;
    dispatch_queue_t checkThread;
    
    
    NSTimer *theTimer;
    int leftTime;
    ECWeakProxy *proxySelf;
    
    BOOL comeErrState;  //遇到异常状态
    BOOL startLiveOne;  //开始检测一个动作
    BOOL oneLiveSuccess;   //检活单个动作成功
    BOOL hasFaceIn;        //人脸是否进入
    
    int betterImgIndex;     //当前挑图的索引
    
    int eyeFrameCount;  //缓冲的眼睛预值帧数；
    int eyeAVGFrame;    //当前人眼睛的均值
    
    BOOL startLostCheck;    //丢帧检测是否开始
    int lastImgScore;// 上张照片分值
    
    int betterImgCount;
    
    // V4.4.3优化业务逻辑
    int fakeFaceCount; // 检测假体连续的帧数
    int realFaceCount; // 检测真正人脸连续帧数
    
    int coverFaceCount; //遮挡判断连续的帧数
    int notCoverFaceCount; //判断未遮挡连续的帧数
    int lastFaceId;     //faceId用于丢帧检测
    
}
@property (nonatomic,strong) ECSSDuck *ssDuck;   //算法工具
@property (nonatomic,assign) BOOL isReadEngin;   //算法是否加载成功
@property (nonatomic,assign) BOOL isDetecting;   //是否正在检测
@property (nonatomic,assign) BOOL isStartLive;   //是否开始检测
@property (nonatomic,assign) ECLiveType currentLive; //当前正在检测的是哪个动作
@property (nonatomic,assign) BOOL isSendFC;      //远近的语音播报发送一次

@property (nonatomic,strong) NSMutableArray *actionArr;//检测动作数组
@property (nonatomic,assign) int oneActionTime;//单个动作超时时间
@property (nonatomic,strong) NSMutableArray *imgArr; //采集的照片数组

// V4.4.3新增记录连续20张图片
// 记录上一张图片是否通过hack检测
/**
 * 记录上一张图片是否通过hack检测
 *
 * 如果通过了,fakeFaceCount重置为0
 * 如果没有,在原fakeFaceCount基础上+1
 * 如果fakeFaceCount>=20,则isPassHacked = NO,此时hack检测不通过
 */
@property (nonatomic,assign)BOOL lastFacePassHacked;   // 上一帧是否通过hack检测,默认YES
@property (nonatomic,assign)BOOL isPassHacked;   // 总体是否通过hack检测,默认YES

@end

@implementation ECFaceDetecter

#pragma mark 使用新版授权方式
- (void)authLicense {
    
    ss_idStr = [NSBundle mainBundle].bundleIdentifier;
   
}

#pragma mark public api

#pragma mark - 许可证信息
+ (NSDictionary *)sdkInfo{
    
    NSBundle *sdkBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[ECLiveConfig share].sdkBundleName ofType:nil]];
    NSString *licPath = [sdkBundle pathForResource:@"EyeCoolLive.lic" ofType:nil];
    NSString *licStr = [NSString stringWithContentsOfFile:licPath encoding:NSUTF8StringEncoding error:nil];
    licStr = [licStr substringFromIndex:64];
    NSRange endRandge = [licStr rangeOfString:@"########## Identification of the Start of the License ##########"];
    licStr = [licStr substringToIndex:endRandge.location];
    NSArray *licArr = [licStr componentsSeparatedByString:@"\r\n"];
    
    NSMutableString *mutStr = [NSMutableString stringWithCapacity:1];
    [mutStr appendString:@"\n"];
    for (NSString *oneStr in licArr) {
        if (oneStr.length >2) {
            [mutStr appendString:oneStr];
            [mutStr appendString:@"\n"];
        }
    }
    
    NSString *curID = [NSBundle mainBundle].bundleIdentifier;

    
    NSDictionary *sdkMsg = @{@"sdk_version":EC_SDK_VERSION,
                             @"ss_version":EC_SS_ALG_VER,
                             @"sdk_build":EC_SDK_BUILD,
                             @"sdk_message":EC_SDK_INFO,
                             @"sdk_license":licArr,
                             @"cur_appid":curID
                            };
    
    return sdkMsg;
}

#pragma mark - 初始化算法
- (instancetype)initWithDat:(NSString *)datPath
                    license:(NSString *)licPath
                   imgWidth:(int )width
                  imgHeight:(int )height{
    
    if (self=[super init]) {
        
        [self authLicense];

        _isReadEngin = NO;
        _isDetecting = NO;
        _isStartLive = NO;
        comeErrState = NO;
        ss_datPath = datPath;
        ss_licPath = licPath;
        ss_Width = width;
        ss_Height = height;
        checkThread = dispatch_queue_create("cn.eyecool.ECFaceDetecterQueue", NULL);
        proxySelf = [ECWeakProxy proxyWithTarget:self];
        self.actionArr = [[NSMutableArray alloc]initWithCapacity:1];
        startLiveOne = YES;
        oneLiveSuccess = NO;
        hasFaceIn = NO;
        self.currentLive = 0;
        self.imgArr = [[NSMutableArray alloc]initWithCapacity:1];
        betterImgIndex = 0;
        _isSendFC = NO;
        
        eyeAVGFrame = 0;
        eyeFrameCount = 0;
        
        startLostCheck = NO;
        
        self.lastFacePassHacked = YES;
        self.isPassHacked = YES;
    }
    
    return self;
    
}



#pragma mark - 开始进行活体检测
//开始进行活体检测(配置检测动作，单个动作检测时间)
- (void)startLiveDetect{
    if (_isStartLive) {
        return;
    }
    
    //默认的一些参数处理(清空动作数组,照片数组)
    [_actionArr removeAllObjects];
    [_imgArr removeAllObjects];
    betterImgIndex = 0;
    
    ///如使用代理方法返回外面设置的动作数组
    if ([self.delegate respondsToSelector:@selector(ECFaceLiveCheckSequence)]) {
        [_actionArr addObjectsFromArray:[self.delegate ECFaceLiveCheckSequence]];
    }else{///默认2个动作(眨眼，张嘴)
        [_actionArr addObject:@(ECLiveEYE)];
        [_actionArr addObject:@(ECLiveMOU)];
    }
    ///第一个动作直视摄像头
    [_actionArr insertObject:@(ECLiveLOOK) atIndex:0];
    
    if ([self.delegate respondsToSelector:@selector(ECFaceLiveOneActionTime)]) {
        self.oneActionTime = [self.delegate ECFaceLiveOneActionTime];
        if (_oneActionTime <5 || _oneActionTime >30) {
            _oneActionTime = 10;
        }
    }else{
        self.oneActionTime = 10;
    }
    
    ///初始化算法引擎处理
    [self startEngin];
    
    ///_isReadEngin = YES 初始化算法成功 开始进行检测 self.isStartLive = YES
    //sleep(1);
    self.isStartLive = _isReadEngin;
    
    //[ECLogUtil addMsg:@"\n"];
    [ECLogUtil addMsg:@"活检开始"];
    lastImgScore = 0;
    betterImgCount = 0;
    [ZJLivePolicy reset];
    // 检活开始,连续假体数量默认0
    fakeFaceCount = 0;
    // 连续真正人脸数量默认0
    realFaceCount = 0;
    // 遮挡次数默认0
    coverFaceCount = 0;
    
}

#pragma mark - 结束进行活体检测
//结束进行活体检测
- (void)stopLiveDetect{
    [self stopTimer];
    [self sendErrorMessage:ECDetectErrorLiveCheckCancel];
    [ECLogUtil addMsg:@"活检测取消了！"];
    [ECLogUtil save];
    if (_isStartLive==NO) {
        return;
    }
    
    //如果刚打开，开头语音还没播完，就关闭，则延时1秒再次关闭timer，当count==0时，表示活检已完成；
    if (_actionArr.count==0) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopTimer];
    });

}

#pragma mark - ========= 读取摄像头压入视频流，开始人脸检活逻辑 =========
- (void)pushDetectBuffer:(CMSampleBufferRef )sampleBuffer
             orientation:(UIDeviceOrientation)orientation{

    //是否启动检活
    if(!_isStartLive){
        return ;
    }
    
    
    //当前帧是否检测完成(检测完成)
    if (_isDetecting) {
        return;
    }
    
    //NSLog(@"推流的图片旋转的方向:%ld",(long)orientation);
    //检测线程(视频流转图片)
    __block UIImage *curImg = [ECImageUtil argbImageFromSampleBuffer:sampleBuffer];
    UIImage * newImage;
    newImage = curImg;
//    if (self.orientation == UIDeviceOrientationPortrait)
//    {
//        newImage = curImg;
//    }
//    else if(self.orientation == UIDeviceOrientationLandscapeRight){
//        newImage = [ECImageUtil getRotationImage:curImg rotation:UIImageOrientationLeft];
//        //newImage = [ECImageUtil argbImageFromSampleBuffer:sampleBuffer];
//    }
//    else if(self.orientation == UIDeviceOrientationLandscapeLeft)
//    {
//        newImage = [ECImageUtil getRotationImage:curImg rotation:UIImageOrientationRight];
//    }

    dispatch_async(checkThread, ^{
        
///是否输出当前帧的检测耗时及当前帧信息
#if EC_EN_LOG_BUFFER_TIME
        CFAbsoluteTime ss1 = CFAbsoluteTimeGetCurrent();
#endif
     
        self.isDetecting = YES;
        [self doFaceCheckOnCheckThread:newImage];
        self.isDetecting = NO;
        curImg = nil;
        
#if EC_EN_LOG_BUFFER_TIME
        CFAbsoluteTime ss2 = CFAbsoluteTimeGetCurrent();
        float liveCheckTM = (ss2 - ss1)*1000;
        NSLog(@"检测当前帧耗时: %.2f 毫秒",liveCheckTM);
#endif
        
    });
    
}

#pragma mark 检活数据帧主入口
//活检主体入口
- (void)doFaceCheckOnCheckThread:(UIImage *)faceImg{
    
    //开始检活
    int cur =[[_actionArr objectAtIndex:0] intValue];
    self.currentLive = cur;
    if (startLiveOne) {///开始检测动作
        startLiveOne = NO;
        [ECLogUtil addMsg:[NSString stringWithFormat:@"开始检测动作：%d",cur]];
        if ([self.delegate respondsToSelector:@selector(ECFaceLiveWillStartCheck:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate ECFaceLiveWillStartCheck:cur];///显示提示文字、播放语音
            });
        }
        //sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startTimerWidthLiveType:cur];///动作时间倒计时
        });
        
    }
    
    ///人脸检测(是否存在人脸)
    ECFaceInfo *face = [self.ssDuck detectFaceWithFrame:faceImg];
    
    // 把图片存储在本地
//    NSData *rgbData = [ECImageUtil rgbDataFromArgbImage:faceImg];
//    NSString * time = [self getNowTimeTimestamp];
//    NSString *picFile = [NSString stringWithFormat:@"%@/%@_%d.bin",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0],time,face.td_scor];
//    [rgbData writeToFile:picFile atomically:YES];
    
#if EC_EN_LOG_BUFFER_TIME
    NSLog(@"当前帧：%@",face);
#endif

    //有人脸
    if (face) {
        if (!startLostCheck &&(cur!=ECLiveLOOK)) {
            lastFaceId = face.faceId;
            startLostCheck = YES;
        }
//        [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸进入，当前检测动作：%d",cur]];
//        hasFaceIn = YES;
//        [self sendLiveStateMessage:ECLiveStateFaceNormal];
        
        //新策略使用faceId判断换人，只在动作阶段校验
        if (startLostCheck && (lastFaceId!=face.faceId) && [ECLiveConfig share].lostDetect &&(cur!=ECLiveLOOK)) {
            [ECLogUtil addMsg:@"检测到换人"];
            [self stopTimer];
            [self sendErrorMessage:ECDetectErrorCurrentFaceLost];
            [ECLogUtil addMsg:@"丢帧检测faceid发生变化：检测到中突换人！检活结束！"];
            [ECLogUtil save];
            return;
        }
        NSDate *date1 = [NSDate date];
        NSDateFormatter *formetter = [[NSDateFormatter alloc]init];
        formetter.dateFormat = @"yyyyMMddHHmmss.**sss**";
        NSString *dateStr1 = [formetter stringFromDate:date1];
        //这里doFaceLiveCheckWithFace在ipad mini上执行速度非常慢
        [self doFaceLiveCheckWithFace:face liveType:cur faceImage:faceImg];
    }else{
        //无人脸
        [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸离开，当前检测动作：%d",cur]];
        [self sendLiveStateMessage:ECLiveStateFaceLeave];
        hasFaceIn = NO;
        comeErrState = YES;
    }
    face = nil;
}

#pragma mark private API

- (void)stopLiveness{
    if (_isStartLive==NO) {
        return;
    }
    self.isStartLive = NO;
    oneLiveSuccess = NO;
    startLiveOne = YES;
    [self stopEngin];
    eyeFrameCount = 0;
    eyeAVGFrame = 0;
}

-(NSString *)getNowTimeTimestamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这一点对时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];
    return timeSp;
}



// V4.4.3 判断hack
#pragma mark 判断hack
- (void)lastFaceImageHackPassedWithFaceImage:(UIImage *)faceImage
{
    int hk = [self.ssDuck hackDetectWithFSPF:faceImage];
    
    // 保存图片的方法
//    NSData *rgbData = UIImagePNGRepresentation(faceImage);
//    NSString * time = [self getNowTimeTimestamp];
//    NSString *picFile = [NSString stringWithFormat:@"%@/%@_%d.jpg",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0],time,face.td_scor];
//    [rgbData writeToFile:picFile atomically:YES];
    if (hk == 10) {
        // 当前帧没有通过hack检测,将lastFacePassHacked = NO
        [ECLogUtil addMsg:[NSString stringWithFormat:@"检测到hack：%d\n",hk]];
        // 人脸丢失
        [self sendLiveStateMessage:ECLiveStateFaceHackNoPass];
        self.lastFacePassHacked = NO;
        realFaceCount = 0;
        fakeFaceCount ++ ;
        comeErrState = YES;
        //NSLog(@"连续第%d张hack没有通过",fakeFaceCount);
    }
    else if(hk == 0)
    {
        // 没有检测到人脸,这里暂时根据情况抛出异常
        if (hasFaceIn == YES)
        {
            [self sendErrorMessage:ECDetectErrorCurrentFaceLost];
        }
    }
    else
    {
        // 当前帧通过了hack检测
        // 此时fakeFaceCount 重置为 0;
        fakeFaceCount = 0;
        realFaceCount ++ ;
        self.lastFacePassHacked = YES;
        //NSLog(@"hack通过,此时fakeFaceCount重置为0.");
    }
            
}

#pragma mark 检活判断是否正常
- (BOOL)checkNormalWithFace:(ECFaceInfo *)face liveType:(int)cur faceImage:(UIImage *)faceImage
{
    //采集正脸，正脸检测
    if (cur == ECLiveLOOK) {
        
        //遮挡判断
        BOOL coverJD = [self.ssDuck coverDetectWithFrame:face.curImage];
        //printf("cover detect=%d\n",coverJD);
        if (coverJD) {
            [ECLogUtil addMsg:[NSString stringWithFormat:@"检测到遮挡 墨镜：%d\n",1]];
            coverFaceCount ++;
            //NSLog(@"检测到遮挡的数量:%d",coverFaceCount);
            return NO;
        }
        else
        {
            notCoverFaceCount ++;
            //NSLog(@"未检测到遮挡的数量:%d",notCoverFaceCount);
        }
        coverFaceCount = 0;
        
        // V4.4.3进行hack检测
        [self lastFaceImageHackPassedWithFaceImage:face.curImage];
        if (fakeFaceCount >= 10)
        {
            NSLog(@"连续%d张hack未通过!",fakeFaceCount);
            [self sendErrorMessage:ECDetectErrorNotLiveFace];
        }
        
        BOOL fdJudge = [ECLivePolicy liveChooseJustFaceImage:face];
        if (fdJudge){
            betterImgCount++;
        }else{
            betterImgCount = 0;
        }
        
        if (fdJudge==NO || betterImgCount <5) {
            comeErrState = YES;
            [ECLogUtil addMsg:[NSString stringWithFormat:@"正脸检测：shrp=%d yaw=%d pitch=%d roll=%d eyed=%d motd=%d %d",face.td_shrp,face.td_yaw,face.td_pitch,face.td_roll,face.td_eyed,face.td_motd,cur]];
            [self sendLiveStateMessage:ECLiveStateNotLookCamera];
            
            return NO;
        }
    }
    
    //人脸太远
    if ([ECLivePolicy liveCheckFaceFarWith:face]) {
        [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸距离屏幕太远，瞳距：%d，当前检测动作：%d",face.td_2eye_d,cur]];
        if (_isSendFC) {
            return NO;
        }
        [self sendLiveStateMessage:ECLiveStateFaceFar];
        comeErrState = YES;
        self.isSendFC = YES;
        return NO;
    }
    
    //人脸太近
    if ([ECLivePolicy liveCheckFaceCloseWith:face]) {
        [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸距离屏幕太近，瞳距：%d，当前检测动作：%d",face.td_2eye_d,cur]];
        if (_isSendFC) {
            return NO;
        }
        [self sendLiveStateMessage:ECLiveStateFaceClose];
        comeErrState = YES;
        self.isSendFC = YES;
        return NO;
    }
    
    //人脸晃动，张嘴眨眼动作，判断XY
    if (cur == ECLiveEYE || cur == ECLiveMOU || cur == ECLiveLOOK) {
        BOOL shakeXY = [ECLivePolicy liveCheckFaceShakeWith:face shakeType:ECShakeFaceXY];
        if (shakeXY) {
            comeErrState = YES;
            [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸晃动，当前检测动作：%d",cur]];
            [self sendLiveStateMessage:ECLiveStateFaceShake];
            return NO;
        }
    }
    
    //人脸晃动检测，左右转头，判断Y
    if (cur == ECLiveYAW) {
        BOOL shakeY = [ECLivePolicy liveCheckFaceShakeWith:face shakeType:ECShakeFaceY];
        if (shakeY) {
            comeErrState = YES;
            [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸晃动，当前检测动作：%d",cur]];
            [self sendLiveStateMessage:ECLiveStateFaceShake];
            return NO;
        }
    }
    
    //人脸晃动检测，上下点头，判断X
    if (cur == ECLiveNOD) {
        BOOL shakeX = [ECLivePolicy liveCheckFaceShakeWith:face shakeType:ECShakeFaceX];
        if (shakeX) {
            comeErrState = YES;
            [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸晃动，当前检测动作：%d",cur]];
            [self sendLiveStateMessage:ECLiveStateFaceShake];
            return NO;
        }
    }
    
    
    //检测到遮挡
    if (coverFaceCount>=1) {
        comeErrState = YES;
        [self sendLiveStateMessage:ECLiveStateFaceHasCover];
        return NO;
    }
    
    
    
    //检测到假体
    if (fakeFaceCount>=12) {
        //[self sendErrorMessage:ECDetectErrorNotLiveFace];
        //return NO;
    }
    
    //回到正常，发一个消息
    if (comeErrState) {
        comeErrState=NO;
        self.isSendFC = NO;
        [ECLogUtil addMsg:[NSString stringWithFormat:@"人脸检测回归正常，当前检测动作：%d",cur]];
        // V4.4.3优化细节
        if (realFaceCount >= 5)
        {
            [self sendLiveStateMessage:ECLiveStateFaceNormal];
        }
        
    }
    
    if (comeErrState == NO && self.isSendFC == NO)
    {
        // V4.4.3优化细节
        if (notCoverFaceCount >= 5 && realFaceCount >= 5)
        {
            [self sendLiveStateMessage:ECLiveStateFaceNormal];
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else{
        return NO;
    }
}

#pragma mark 检活主逻辑流程
- (void)doFaceLiveCheckWithFace:(ECFaceInfo *)face liveType:(int)cur faceImage:(UIImage *)faceImage{
    
    /*
    //清晰度检测，可能光线不足，该状态受光线影响严重，不稳定，暂不对外抛状态；
    if ([ECLivePolicy liveCheckFaceDefinitionWith:face]) {
        comeErrState = YES;
        //[self sendLiveStateMessage:ECLiveStateFaceDefinitionLow];
        [ECLogUtil addMsg:[NSString stringWithFormat:@"光线不好，清晰度不够，清晰度：%d，当前检测动作：%d",face.td_shrp,cur]];
        return;
    }
     */
    
    /*
    //printf("hack=%d\n",face.hackScore);
    //hack
    if (face.hackScore < 90) {
        [ECLogUtil addMsg:[NSString stringWithFormat:@"检测到hack：%d\n",face.hackScore]];
        return;

    }
     */
    
    //NSLog(@"主流程人脸属性:%@",face);
    BOOL isNormal =  [self checkNormalWithFace:face liveType:cur faceImage:faceImage];
    
    if (isNormal == YES)
    {
        //挑图
        if (_imgArr.count == betterImgIndex) {
            [ECLogUtil addMsg:[NSString stringWithFormat:@"挑图添加首张，当前检测动作：%d",cur]];
            [_imgArr insertObject:face.curImage atIndex:betterImgIndex];
            lastImgScore = face.td_scor;
        }
        
        
        //挑图策略new
        if (face.td_scor >= lastImgScore) {
            lastImgScore = face.td_scor;
            [ECLogUtil addMsg:[NSString stringWithFormat:@"挑图发现更好的图了，当前检测动作：%d",cur]];
            [_imgArr replaceObjectAtIndex:betterImgIndex withObject:face.curImage];
        }


        
        NSString *faceInfo = [NSString stringWithFormat:@"ECFaceInfo: 置信度=%d, 清晰度=%d, 眼睛张开度=%d, 嘴巴张开度=%d, 左右转头度=%d, 抬低头度=%d, 左右歪头度=%d, 双眼间距离=%d, 坐标(x=%d,y=%d,w=%d,h=%d)",face.td_scor,face.td_shrp,face.td_eyed,face.td_motd,face.td_yaw,face.td_pitch,face.td_roll,face.td_2eye_d,face.td_rectX,face.td_rectY,face.td_rectW,face.td_rectH];
        [ECLogUtil addMsg:faceInfo];
        
            
        //合格的人脸数据，压帧检测动作
        switch (cur) {
            case ECLiveEYE:
            {
                BOOL fdJudge = [ECLivePolicy liveChooseJustFaceImage:face];
                if (fdJudge == NO)
                {
                    [self sendLiveStateMessage:ECLiveStateNotLookCamera];
                }
                oneLiveSuccess = [_ssDuck detectBlinkWithFrame:face.curImage];
                if(oneLiveSuccess==NO){
                    oneLiveSuccess = [ZJLivePolicy detectLive:1 threshold:[ECLiveConfig share].eyeThres cur:face.td_eyed];
                }
            }
                break;
            case ECLiveMOU:
            {
                oneLiveSuccess = [ZJLivePolicy detectLive:2 threshold:[ECLiveConfig share].mouThres cur:face.td_motd];
            }
                break;
            case ECLiveYAW:
            {
                oneLiveSuccess = [ZJLivePolicy detectLive:3 threshold:[ECLiveConfig share].yawThres cur:face.td_yaw];
            }
                break;
            case ECLiveNOD:
            {
                oneLiveSuccess = [ZJLivePolicy detectLive:4 threshold:[ECLiveConfig share].pitThres cur:face.td_pitch];
            }
                break;
            case ECLiveLOOK:
                if (realFaceCount >= 5)
                {
                    // V4.4.3优化业务逻辑
                    oneLiveSuccess = [ECLivePolicy liveCheckLookCameraWith:face];
                    comeErrState = NO;
                    //NSLog(@"连续%d帧hack检测通过检测,直视结果:%d",realFaceCount,oneLiveSuccess);
                }
                break;
            default:
                oneLiveSuccess = NO;
                break;
        }
        
        if (oneLiveSuccess){
            oneLiveSuccess = NO;
            startLiveOne = YES;
            betterImgIndex++;
            [[CCQueue shareWithCount:0] clear];
            [self stopTimer];
            [ECLogUtil addMsg:[NSString stringWithFormat:@"检活动作通过，当前检测动作：%d",cur]];
            if ([self.delegate respondsToSelector:@selector(ECFaceLiveDidCompleteCheck:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate ECFaceLiveDidCompleteCheck:cur];
                });
                sleep(1);
            }
            [_actionArr removeObjectAtIndex:0];
            //活检测成功
            if (_actionArr.count==0) {
                //把正采照的值检测输出到log
                ECFaceInfo *betFace = [self.ssDuck detectFaceWithFrame:[self.imgArr objectAtIndex:0]];
                NSString *betfInfo = [NSString stringWithFormat:@"正脸照信息：置信度=%d, 清晰度=%d, 眼睛张开度=%d, 嘴巴张开度=%d, 左右转头度=%d, 抬低头度=%d, 左右歪头度=%d, 双眼间距离=%d, 坐标(x=%d,y=%d,w=%d,h=%d)",betFace.td_scor,betFace.td_shrp,betFace.td_eyed,betFace.td_motd,betFace.td_yaw,betFace.td_pitch,betFace.td_roll,betFace.td_2eye_d,betFace.td_rectX,betFace.td_rectY,betFace.td_rectW,betFace.td_rectH];
                [ECLogUtil addMsg:betfInfo];
                
                [self stopLiveness];
                [ECLogUtil addMsg:[NSString stringWithFormat:@"活检成功，当前检测动作：%d",cur]];
                
                /**
                 * V4.4.3版本新增功能
                 *
                 * 在检活成功回调之前,对所有图片做一次Hack检测
                 * 并不会消耗很多资源,能有效避免(视频,假体,图片等)攻击
                 */
                NSArray *capedArr = [NSArray arrayWithArray:self.imgArr];
                BOOL imagesHackPassed = [self hackDetectWithFaceImagesArray:capedArr];
                if (imagesHackPassed == YES)
                {
                    // 所有图片hack检测通过,才可以回调成功
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self liveCheckSuccessFull];
                    });
                }
                else
                {
                    // 否则回调检活失败
                    [self sendErrorMessage:ECDetectErrorNotLiveFace];
                }
            }
        }
    }
    
}

#pragma mark ----- 回调前对图片数组做Hack检测 -----
/**
 * V4.4.3版本新增功能
 * 在检活成功回调之前,对所有图片做一次Hack检测
 * 并不会消耗很多资源,能有效避免(视频,假体,图片等)攻击
 *
 * @param faceImagesArray 需要回调的检活图片数组
 *
 * 返回
 * hack是否通过
*/
- (BOOL)hackDetectWithFaceImagesArray:(NSArray *)faceImagesArray
{
    int noPassCount = 0;
    BOOL isPassed = YES;
    for (int i = 0 ; i < faceImagesArray.count ; i ++) {
        UIImage * faceImage = [faceImagesArray objectAtIndex:i];
        
        // 保存图片的方法
        NSData *rgbData = UIImagePNGRepresentation(faceImage);
        NSString *picFile = [NSString stringWithFormat:@"%@/error_img_%d.jpg",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0],i+1];
        [rgbData writeToFile:picFile atomically:YES];
        int hk = [self.ssDuck hackDetectWithFSPF:faceImage];
        if (hk == 10 || hk == 0) {
            noPassCount ++;
            [ECLogUtil addMsg:[NSString stringWithFormat:@"图片第%d张,hack没有通过!",i+1]];
        }
        else
        {
            [ECLogUtil addMsg:[NSString stringWithFormat:@"图片第%d张,hack通过!",i+1]];
        }
    }
    if (noPassCount >= 1) {
        // 如果
        isPassed = NO;
    }
    else
    {
        isPassed = YES;
    }
    return isPassed;
}

#pragma mark 活检成功处理
- (void)liveCheckSuccessFull{
    [ECLogUtil save];
    [self stopLiveness];
   // [_imgArr insertObject:_campBetterImg atIndex:0];
    NSArray *capedArr = [NSArray arrayWithArray:self.imgArr];
    [self.imgArr removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(ECFaceLiveCheckSuccessGetImage:)]) {
            [self.delegate ECFaceLiveCheckSuccessGetImage:capedArr];
        }
    });

    
}



#pragma mark Timer 定时器处理
- (void)startTimerWidthLiveType:(int )liveType{
    [self stopTimer];
    theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:proxySelf selector:@selector(timerScheduleAction) userInfo:@(liveType) repeats:YES];
    leftTime = _oneActionTime;
    [theTimer fire];
}

- (void)stopTimer
{
    if (theTimer) {
        [theTimer invalidate];
        theTimer = nil;
    }
}

- (void)timerScheduleAction{
    leftTime -=1;
    if (_isStartLive == NO) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(ECFaceCheckOneLive:leftTime:)]) {
        [self.delegate ECFaceCheckOneLive:[[theTimer userInfo] intValue] leftTime:leftTime];
    }

    

    
    if (leftTime==0) {
        
        //如果最后2秒没有人脸，则认为是超时没人脸，其他为超时动作不通过
        int TIME_OUT_ST = ECDetectErrorTimeOutNoPass;
        if ( hasFaceIn == NO && comeErrState) {//没有人脸，人脸异常
            TIME_OUT_ST = ECDetectErrorTimeOutNoFace;
            [ECLogUtil addMsg:@"超时，未检测到人脸！"];
        }else{
            [ECLogUtil addMsg:@"超时，动作未通过！"];
        }
        
        [ECLogUtil save];
        [self stopTimer];
        [self sendErrorMessage:TIME_OUT_ST];

    }
}

#pragma mark 算法引擎处理
- (void)startEngin {
    if (_isReadEngin) {
        return;
    }
    self.ssDuck = [[ECSSDuck alloc] init];
    _isReadEngin = NO;
    
    ECSSState state = [_ssDuck initEnginWithDat:ss_datPath license:ss_licPath bindID:ss_idStr imgWidth:ss_Width imgHeight:ss_Height];
    
    ECDetectError detectError = ECDetectErrorDuckInitOther;
    switch (state) {
        case ECSSInitOK:
            _isReadEngin = YES;
            break;
        case ECSSDatNotExist:
            detectError = ECDetectErrorDuckDatNotExist;
            break;
        case ECSSLicNotExist:
            detectError = ECDetectErrorDuckLicNotExist;
            break;
        case ECSSExpiration:
            detectError = ECDetectErrorDuckExpiration;
            break;
        case ECSSNotMatch:
            detectError = ECDetectErrorDuckNotMatch;
            break;
        default:
            detectError = ECDetectErrorDuckInitOther;
            break;
    }
    
//#if EC_EN_LOG_SSALG_INFO
    NSLog(@"%@",[ECSSDuck version]);
    //NSLog(@"算法初始化：%d %d,传入的宽:%ld,高:%ld",_isReadEngin,state,ss_Width,ss_Height);
//#endif
    
    if (!_isReadEngin) {
        [self sendErrorMessage:detectError];
        return;
    }
    
    _isReadEngin = YES;
}

- (void)stopEngin{
    
    if (_isReadEngin==NO) {
        return;
    }
    
    dispatch_async(checkThread, ^{
        BOOL noneComlete = YES;
        while (noneComlete) {
            if (self.isDetecting==NO) {
                BOOL ret = [self.ssDuck deinitEngin];
#if EC_EN_LOG_SSALG_INFO
                NSLog(@"算法卸载：%d",ret);
#endif
                ret = -1;
                self.isReadEngin = NO;
                noneComlete = NO;
            }
        }
    });
}

#pragma mark 其他
//发送检活状态消息
- (void)sendLiveStateMessage:(ECLiveState )state
{
    //修复一处bug，在人脸刚离开的时刻并且点取消，有可能崩溃
    if(_isStartLive == NO)
    {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(ECFaceLiveState:liveType:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate ECFaceLiveState:state liveType:self.currentLive];
        });
    }
}

#pragma mark - ========= 发送错误失败代理事件(调用代理,到检测结果页面提示错误信息) =========
//发送错误失败代理事件
- (void)sendErrorMessage:(ECDetectError )aErr{
    [self stopLiveness];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(ECFaceDetecterWithError:liveType:)]) {
            [self.delegate ECFaceDetecterWithError:aErr liveType:self.currentLive];
        }
    });

}

- (void)dealloc
{
    checkThread = nil;
    theTimer = nil;
    proxySelf = nil;
    _ssDuck = nil;
    _actionArr = nil;
    _imgArr = nil;
    [CCQueue destory];
    [ECLogUtil destory];
    //NSLog(@"FaceDetector dealloc");
}


/*
- (BOOL)delayTime:(NSTimeInterval)tm{
    
    if (!stDate) {
        stDate = [NSDate date];
    }
    edDate = [NSDate date];
    if ([edDate timeIntervalSinceDate:stDate]>=tm) {
        stDate = nil;
        edDate = nil;
        return NO;
    }
    return YES;
}

 */
@end
