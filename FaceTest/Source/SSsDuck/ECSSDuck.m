//
//  ECSSDuck.m
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/27.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import "ECSSDuck.h"
#import "SsDuck.h"
#import "ECLogUtil.h"


@interface ECSSDuck ()
{
    void *henvP;
    BOOL bInitEngin;
}

@end

@implementation ECSSDuck

- (instancetype)init{
    if (self=[super init]) {
        
        henvP = NULL;
        bInitEngin = NO;
        
    }
    
    return self;
}

+ (NSString *)version{
    int ntype = 0;
    char sfinfo[1024] = {0};
    int ret = SsMobiVersn(ntype,sfinfo);
    if (ret<0) {
        NSLog(@"ECSSDuck: 获取版本号错误：%d",ret);
        return @"";
    }
    return  [NSString stringWithCString:sfinfo encoding:NSUTF8StringEncoding];
}

- (ECSSState)initEnginWithDat:(NSString *)datPath
                 license:(NSString *)licPath
                  bindID:(NSString *)idStr
                imgWidth:(int )width
               imgHeight:(int )height{
    
    ECSSState ssState = ECSSOther;
    
    if (bInitEngin) {
        ssState = ECSSInitOK;
        return ssState;
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:datPath]==NO){
        NSLog(@"ECSSDuck: dat文件不存在！");
        ssState = ECSSDatNotExist;
        return ssState;
    }
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:licPath]==NO){
        NSLog(@"ECSSDuck: license 授权文件不存在！");
        ssState = ECSSLicNotExist;
        return ssState;
    }
    
    
    int ret = -100;
    ret = SsSetDatFile(datPath.UTF8String,0,0);
    if(ret<0){
        NSLog(@"ECSSDuck: SsSetDatFile=%d",ret);
        ssState = ECSSOther;
        return ssState;
    }
    
    
    //190912,使用新的授权文件机制策略
    ret = -100;
    ret = SsMobiLicIsOk(licPath.UTF8String, 0, idStr.UTF8String);
    //包名不匹配
    if(ret == -7){
        NSLog(@"ECSSDuck: SsMobiLicIsOk id=%@ ret=%d",idStr,ret);
        ssState = ECSSNotMatch;
        return ssState;
    }
    //时间过期
    if(ret == -20 || (ret == -21))
    {
        NSLog(@"ECSSDuck: SsMobiLicIsOk id=%@ ret=%d",idStr,ret);
        ssState = ECSSExpiration;
        return ssState;
    }
    //其他错误
    if (ret < 0) {
        NSLog(@"ECSSDuck: SsMobiLicIsOk id=%@ ret=%d",idStr,ret);
        ssState = ECSSOther;
        return ssState;
    }
    //printf("LicRet=%d\n",ret);
    
    ret = -100;
    
    //初始化
    ret = SsMobiDinit(&henvP,width,height,1,NULL,NULL);
//    ret = SsMobiDinit(&henvP,height,width,1,NULL,NULL);
    if(ret<0){
        NSLog(@"ECSSDuck: Dinit=%d",ret);
        ssState = ECSSOther;
        return ssState;
    }
    bInitEngin = YES;
    ssState = ECSSInitOK;
    return ssState;
}


- (ECFaceInfo *)detectFaceWithFrame:(UIImage *)argbImg{
    if (!bInitEngin || !argbImg) {return nil;}
    
    NSData *rgbData = [ECImageUtil rgbDataFromArgbImage:argbImg];

    
    int ret = -100;
    ret = SsMobiFrame(rgbData.bytes, 0, 0, henvP);
    //NSLog(@"是否检测到人脸SsMobiFrame:%d",ret);
    
    if (ret<1) {
        return nil;
    }
    else
    {
        // 检测到了人脸,把框变绿
    }
    
    ECFaceInfo *faceInfo = [[ECFaceInfo alloc]init];
    int scor = 0;
    //TD_SCOR 质量分数
    //NSLog(@"SsMobiIsoGo TD_SCOR:[%s-%d]",__FUNCTION__,__LINE__);
    SsMobiIsoGo(TD_SCOR, &scor, 0, 0, henvP);
    //NSLog(@"SsMobiIsoGo TD_SCOR:[%s-%d]",__FUNCTION__,__LINE__);
    faceInfo.td_scor = scor;
    
    int eyed = 0;
    //TD_EYED 眨眼0-1
    //NSLog(@"SsMobiIsoGo TD_EYED:[%s-%d]",__FUNCTION__,__LINE__);
    SsMobiIsoGo(TD_EYED, &eyed, 0, 0, henvP);
    //NSLog(@"SsMobiIsoGo TD_EYED:[%s-%d]",__FUNCTION__,__LINE__);
    faceInfo.td_eyed = eyed;
    
    int motd = 0;
    //TD_MOTD 张嘴0-100
    //NSLog(@"SsMobiIsoGo TD_MOTD:[%s-%d]",__FUNCTION__,__LINE__);
    SsMobiIsoGo(TD_MOTD, &motd, 0, 0, henvP);
    //NSLog(@"SsMobiIsoGo TD_MOTD:[%s-%d]",__FUNCTION__,__LINE__);
    faceInfo.td_motd = motd;
    
    int pos[3] = {0};
    //TD_POSE 头部的3D姿态
    //NSLog(@"SsMobiIsoGo TD_POSE:[%s-%d]",__FUNCTION__,__LINE__);
    SsMobiIsoGo(TD_POSE,pos,0,0,henvP);
    //NSLog(@"SsMobiIsoGo TD_POSE:[%s-%d]",__FUNCTION__,__LINE__);
    faceInfo.td_yaw = pos[1];
    faceInfo.td_pitch = pos[0];
    faceInfo.td_roll = pos[2];
    
    
    int rect[4] = {0};
    //TD_RECT 人脸矩形位置
    //NSLog(@"SsMobiIsoGo TD_RECT:[%s-%d]",__FUNCTION__,__LINE__);
    SsMobiIsoGo(TD_RECT,rect,0,0,henvP);
    //NSLog(@"SsMobiIsoGo TD_RECT:[%s-%d]",__FUNCTION__,__LINE__);
    faceInfo.td_rectX = rect[0];
    faceInfo.td_rectY = rect[1];
    faceInfo.td_rectW = rect[2];
    faceInfo.td_rectH = rect[3];
    faceInfo.td_2eye_d = (rect[2]/2.0f);
    
    int tdshrp = 0;
    //NSLog(@"SsMobiIsoGo TD_SHRP:[%s-%d]",__FUNCTION__,__LINE__);
    SsMobiIsoGo(TD_SHRP, &tdshrp, 0, 0, henvP);
    //NSLog(@"SsMobiIsoGo TD_SHRP:[%s-%d]",__FUNCTION__,__LINE__);
    faceInfo.td_shrp = tdshrp;
    
    int fid = 0;
    //NSLog(@"SsMobiIsoGo TD_FCID:[%s-%d]",__FUNCTION__,__LINE__);
    fid = SsMobiIsoGo(TD_FCID,&fid,0,0,henvP);
    //NSLog(@"SsMobiIsoGo TD_FCID:[%s-%d]",__FUNCTION__,__LINE__);
    faceInfo.faceId = fid;

    int sumScore = tdshrp + eyed - motd - abs(pos[0]) - abs(pos[1]) - abs(pos[2]);
    faceInfo.td_scor = sumScore;
    
    //取鼻尖点判断晃动
    int POINT[106*2] = {0};
    //NSLog(@"SsMobiIsoGo TD_PLOC:[%s-%d]",__FUNCTION__,__LINE__);
    SsMobiIsoGo(TD_PLOC,POINT,0,0,henvP);
    //NSLog(@"SsMobiIsoGo TD_PLOC:[%s-%d]",__FUNCTION__,__LINE__);
    faceInfo.td_rectX = POINT[69*2];
    faceInfo.td_rectY = POINT[69*2+1];


    /*
    int hack = 0;
    ret = SsMobiIsoGo(TD_HACK, &hack, 0, 0, henvP);
    //printf("hack-%d-%d\n",ret,hack);
    if (ret<0) {
        faceInfo.hackScore = 100;
    }else{
        faceInfo.hackScore = hack;
    }
     */

    faceInfo.curImage = argbImg;
        
    return faceInfo;
}


//眨眼检测
- (BOOL)detectBlinkWithFrame:(UIImage *)argbImg{
    if (!bInitEngin || !argbImg) {return NO;}
    
    NSData *rgbData = [ECImageUtil rgbDataFromArgbImage:argbImg];
    int ret = -100;
    ret = SsMobiFrame((const unsigned char *)rgbData.bytes, 0, 0, henvP);
    if (ret<1) {return NO;}
    
    int blik = 0;
    //NSLog(@"SsMobiIsoGo TD_ETAT:[%s-%d]",__FUNCTION__,__LINE__);
    SsMobiIsoGo(TD_ETAT, &blik, 0, 0, henvP);
    //NSLog(@"SsMobiIsoGo TD_ETAT:[%s-%d]",__FUNCTION__,__LINE__);
    [ECLogUtil addMsg:[NSString stringWithFormat:@"眨眼检测：%d",blik]];
    if (blik > 50) {
        return YES;
    }
    
    return NO;
    
}

//hack检测
- (int)hackDetectWithFSPF:(UIImage *)argbImg{
    if (!bInitEngin || !argbImg) {return 100;}
    int ret = -100;
    
    NSData *rgbData = [ECImageUtil rgbDataFromArgbImage:argbImg];
    ret = SsMobiFrame((const unsigned char *)rgbData.bytes, 0, 0, henvP);
    //if (ret<1) {return 100;}
    if (ret >= 1) {
        int hack[2] = {0};
        //NSLog(@"SsMobiIsoGo TD_FSPF:[%s-%d]",__FUNCTION__,__LINE__);
        ret = SsMobiIsoGo(TD_FSPF, hack, 0, 0, henvP);
        //NSLog(@"SsMobiIsoGo TD_FSPF:[%s-%d]",__FUNCTION__,__LINE__);
        //NSLog(@"新算法检测的ret:%d",ret);
        //NSLog(@"新算法检测的hack[0]:%d,hack[1]:%d",hack[0],hack[1]);
        if (ret<0) {return 0;}
        //if (hack[0] < 90 || hack[1] < 90 || hack[2] < 90) {
        //邮储修改
        if (hack[0] < 90 || hack[1] < 90) {
            return 10;
        }
        return 100;
    }
    else{
        return 0;
    }    
}

//遮挡检测
- (BOOL)coverDetectWithFrame:(UIImage *)argbImg{
    if (!bInitEngin || !argbImg) {return NO;}
    
    NSData *rgbData = [ECImageUtil rgbDataFromArgbImage:argbImg];
    int ret = -100;
    ret = SsMobiFrame((const unsigned char *)rgbData.bytes, 0, 0, henvP);
    if (ret<1) {return NO;}
    
    //眼镜、口罩和墨镜
    int cover[3] = {0};
    //NSLog(@"SsMobiIsoGo TD_COVER:[%s-%d]",__FUNCTION__,__LINE__);
    ret = SsMobiIsoGo(TD_COVER, cover, 0, 0, henvP);
    //NSLog(@"SsMobiIsoGo TD_COVER:[%s-%d]",__FUNCTION__,__LINE__);
    //表示检测到墨镜或者口罩
    if (ret<0) {return NO;}
    if (cover[1] > 50 || cover[2] > 50) {
        return YES;
    }
    return NO;
}



- (BOOL)deinitEngin{
    
    if (bInitEngin==NO) {
        return YES;
    }
    
    int ret = -100;
    /*
    ret = SsSetDatFile(NULL, 0, 0);
    if (ret<0) {
        NSLog(@"ECSSDuck: SsSetDatFile NULL =%d",ret);
        return NO;
    }
     */
    
    ret = -100;
    ret = SsMobiDexit(henvP);
    if (ret<0) {
        NSLog(@"ECSSDuck: SsMobiDexit=%d",ret);
        return NO;
    }
    bInitEngin = NO;
    henvP = NULL;
    return YES;
}



- (void)dealloc
{
    henvP = NULL;
    //NSLog(@"SSDuck dealloc");
}

@end
