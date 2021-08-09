//
//  ECXMLConfig.m
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/16.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import "ECXMLConfig.h"
#import "ECLiveConfig.h"
#import "ECFaceViewController.h"

static ECXMLConfig *xmlCFG = nil;

@interface ECXMLConfig ()<NSXMLParserDelegate>

@property (nonatomic,strong)NSString *xmlStr;
@property (nonatomic,strong)NSXMLParser *xmlParse;
@property (nonatomic,strong)NSMutableDictionary *mutDic;
@property (nonatomic,strong)NSString *curVale;

@end

@implementation ECXMLConfig

+ (void)confFaceSDKFromXMLString:(NSString *)xmlStr{
    if (!xmlStr || xmlStr.length <10) {
        return;
    }
    if (xmlCFG) {
        return;
    }
    xmlCFG = [[ECXMLConfig alloc]init];
    xmlCFG.xmlStr = xmlStr;
    xmlCFG.mutDic = [[NSMutableDictionary alloc]initWithCapacity:1];
    [xmlCFG startXMLParser];
    xmlCFG = nil;
    
}

- (void)startXMLParser{
    self.xmlParse = [[NSXMLParser alloc]initWithData:[_xmlStr dataUsingEncoding:NSUTF8StringEncoding]];
    _xmlParse.delegate = self;
    [_xmlParse parse];
}


#pragma mark XMLParser delegate

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"ECFaceSDK xml解析出错1，启用默认参数配置：%@",parseError);
}
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    //
    NSLog(@"ECFaceSDK xml解析出错2，启用默认参数配置：%@",validationError);
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    if (_mutDic) {
        [_mutDic removeAllObjects];
    }
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    //NSLog(@"start: %@ %@",elementName,qName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"Value:%@",string);
    _curVale = string;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    
    //NSLog(@"end: %@ %@",elementName,qName);
    if (_curVale.length > 0 && elementName) {
        [self.mutDic setObject:_curVale forKey:elementName];
    }
    
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    if (self.mutDic.count >0) {
        [self doEnumerateElementForSetUp];
    }
    xmlCFG = nil;
    
}

#pragma mark 参数处理

- (void)doEnumerateElementForSetUp{

    //以下参数的默认值可以在 ECLiveConfig.m 里面配置
    
    //眨眼
    NSString *eyeDegree = [_mutDic objectForKey:@"eyeDegree"];
    if ([self currentVale:eyeDegree isInMin:0 max:50]){
        [ECLiveConfig share].eyeThres = [eyeDegree intValue];
    }
    
    //张嘴
    NSString *mouthDegree = [_mutDic objectForKey:@"mouthDegree"];
    if ([self currentVale:mouthDegree isInMin:0 max:50]){
        [ECLiveConfig share].mouThres = [mouthDegree intValue];
    }
    
    //转头
    NSString *headHigh = [_mutDic objectForKey:@"rawDegree"];
    if ([self currentVale:headHigh isInMin:0 max:50]){
        [ECLiveConfig share].yawThres = [headHigh intValue];
    }
    
    //头点
    NSString *headLeft = [_mutDic objectForKey:@"pitchDegree"];
    if ([self currentVale:headLeft isInMin:0 max:50]){
        [ECLiveConfig share].pitThres = [headLeft intValue];
    }
    
    
    //压缩比
    NSString *imgCompress = [_mutDic objectForKey:@"imgCompress"];
    if ([self currentVale:imgCompress isInMin:10 max:100]){
        [ECLiveConfig share].imgCompress = [imgCompress intValue];
    }
    
    //语音
    NSString *isAudio = [_mutDic objectForKey:@"isAudio"];
    if ([self currentVale:isAudio isInMin:0 max:1]){
        [ECLiveConfig share].isAudio = [isAudio intValue];
    }
    
    //打log
    NSString *isLog = [_mutDic objectForKey:@"isLog"];
    if ([self currentVale:isLog isInMin:0 max:1]){
        [ECLiveConfig share].isLog = [isLog intValue];
    }
    

    
    //最大瞳距
    NSString *pupilDistMax = [_mutDic objectForKey:@"pupilDistMax"];
    if ([self currentVale:pupilDistMax isInMin:130 max:220]){
        [ECLiveConfig share].pupilDistMax = [pupilDistMax intValue];
    }
    
    //最小瞳距
    NSString *pupilDistMin = [_mutDic objectForKey:@"pupilDistMin"];
    if ([self currentVale:pupilDistMin isInMin:60 max:150]){
        [ECLiveConfig share].pupilDistMin = [pupilDistMin intValue];
    }
    
    //晃动检测值
    NSString *shakeDegree = [_mutDic objectForKey:@"shakeDegree"];
    if ([self currentVale:shakeDegree isInMin:10 max:80]){
        [ECLiveConfig share].shakeMax = [shakeDegree intValue];
    }
    
    //单个动作超时时间
    NSString *timeOut = [_mutDic objectForKey:@"timeOut"];
    if ([self currentVale:timeOut isInMin:5 max:30]){
        [ECLiveConfig share].timeOut = [timeOut intValue];
    }
    
    //摄像头位置
    NSString *deviceIdx = [_mutDic objectForKey:@"deviceIdx"];
    if ([self currentVale:deviceIdx isInMin:0 max:1]){
        [ECLiveConfig share].deviceIdx = [deviceIdx intValue];
    }
    
    
#pragma mark 动作配置
    /**
        处理动作配置
     */
    NSString *actionList = [_mutDic objectForKey:@"actionList"];
    NSString *actionOrder = [_mutDic objectForKey:@"actionOrder"];

    NSArray *calOrder = [self doActionArrWithlist:actionList order:actionOrder];
    NSMutableArray *liveArr = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < calOrder.count; i++) {
        int curLive = [[calOrder objectAtIndex:i] intValue];
        switch (curLive) {
            case ECLivenessEYE:
                [liveArr addObject:@(ECLivenessEYE)];
                break;
            case ECLivenessMOU:
                [liveArr addObject:@(ECLivenessMOU)];
                break;
            case ECLivenessYAW:
                [liveArr addObject:@(ECLivenessYAW)];
                break;
            case ECLivenessNOD:
                [liveArr addObject:@(ECLivenessNOD)];
                break;
            default:
                break;
        }
    }
    
    
    [ECLiveConfig share].liveTypeArr = liveArr;
    

    /*
    //测试用例
    [self doActionArrWithlist:@"1278" order:@"1*"];
    [self doActionArrWithlist:@"1278" order:@"1*8"];
    [self doActionArrWithlist:@"1278" order:@"*"];
    [self doActionArrWithlist:@"1278" order:@"*1"];
    [self doActionArrWithlist:@"1278" order:@"**1"];
    [self doActionArrWithlist:@"121" order:@"12"];
    [self doActionArrWithlist:@"1278" order:@"11*"];
    [self doActionArrWithlist:@"8" order:@"11*"];
    [self doActionArrWithlist:@"8" order:@"1*"];
     */


}


//处理返回新的数组
- (NSArray *)doActionArrWithlist:(NSString *)actionList order:(NSString *)actionOrder{
    
    //NSLog(@"src:%@",actionList);
    //NSLog(@"src:%@",actionOrder);
    
    NSArray *acList = [self str2arr:actionList];
    NSArray *acOrder = [self str2arr:actionOrder];
    
    
    NSArray *defList = @[[NSString stringWithFormat:@"%d",ECLivenessEYE],
                         [NSString stringWithFormat:@"%d",ECLivenessMOU],
                         [NSString stringWithFormat:@"%d",ECLivenessYAW],
                         [NSString stringWithFormat:@"%d",ECLivenessNOD]];
    NSArray *defOrder = @[[NSString stringWithFormat:@"%d",ECLivenessMOU],@"*"];
    
    if (acList.count <1) {
        acList = defList;
    }
    if (acOrder.count <1) {
        acOrder = defOrder;
    }
    if (acList.count < acOrder.count) {
        acList = defList;
    }
    
    NSSet *allSet = [NSSet setWithArray:@[[NSString stringWithFormat:@"%d",ECLivenessEYE],
                                          [NSString stringWithFormat:@"%d",ECLivenessMOU],
                                          [NSString stringWithFormat:@"%d",ECLivenessYAW],
                                          [NSString stringWithFormat:@"%d",ECLivenessNOD]
                                          ,@"*"]];
    NSSet *listSet = [NSSet setWithArray:@[[NSString stringWithFormat:@"%d",ECLivenessEYE],
                                           [NSString stringWithFormat:@"%d",ECLivenessMOU],
                                           [NSString stringWithFormat:@"%d",ECLivenessYAW],
                                           [NSString stringWithFormat:@"%d",ECLivenessNOD]]];
    NSSet *actionListSet = [NSSet setWithArray:acList];
    NSSet *actionOrderSet = [NSSet setWithArray:acOrder];
    //校验到非法字符,
    if ([actionListSet isSubsetOfSet:listSet]==NO) {
        acList = defList;
    }
    //校验重复
    if ([self isArrHasRepeatElement:acList]) {
        acList = defList;
    }
    if ([actionOrderSet isSubsetOfSet:allSet]==NO) {
        acOrder = defOrder;
    }
    if ([self isArrHasRepeatElement:acOrder]) {
        acOrder = defOrder;
    }
    
    NSArray *finalOrder = [self randomOrderArr:acOrder inListArr:acList];
    //NSLog(@"final:%@",finalOrder);
    
    return finalOrder;
}

//处理组合
- (NSArray *)randomOrderArr:(NSArray *)orderArr inListArr:(NSArray *)listArr{
    
    NSMutableArray *tempList = [NSMutableArray arrayWithArray:listArr];
    NSMutableArray *tempOrder = [NSMutableArray arrayWithArray:orderArr];
    //去重复
    for (int i = 0; i < orderArr.count; i++) {
        NSString *curV = [orderArr objectAtIndex:i];
        [tempList containsObject:curV];
        [tempList removeObject:curV];
    }
    
    for (int i = 0; i < orderArr.count; i++) {
        NSString *curV = [orderArr objectAtIndex:i];
        if ([curV isEqualToString:@"*"]) {
            [self kk_shuffle:tempList];
            [tempOrder replaceObjectAtIndex:i withObject:[tempList objectAtIndex:0]];
            [tempList removeObjectAtIndex:0];
        }
    }
    
    return [NSArray arrayWithArray:tempOrder];
}

//随机
- (void)kk_shuffle:(NSMutableArray *)theArray
{
    int count = (int )[theArray count];
    for (int i = 0; i < count; ++i) {
        int n = (arc4random() % (count - i)) + i;
        [theArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}


//判断是否是数字，并且值在范围
- (BOOL)currentVale:(NSString *)curV isInMin:(int )min max:(int )max
{
    if (!curV) {
        return NO;
    }
    if (![self isNumber:curV]) {
        return NO;
    }
    int intV = curV.intValue;
    if (intV >= min && intV <=max) {
        return YES;
    }
    
    return NO;
}


//判断是否是数字
- (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    NSScanner *scan = [NSScanner scannerWithString:strValue];
    int value;
    return [scan scanInt:&value] && [scan isAtEnd];
}

//字符串转数组
- (NSArray *)str2arr:(NSString *)str
{
    if(!str ||str.length<1)
    {
        return [NSArray array];
    }
    NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < str.length; i++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        [mutArr addObject:substr];
    }
    return [NSArray arrayWithArray:mutArr];
}

//判断是否有重复元素,*不算，避免出现 [1,1,2]
- (BOOL)isArrHasRepeatElement:(NSArray *)arr{
    if (arr.count <2) {
        return NO;
    }
    
    int ct1 = 0;
    int ct2 = 0;
    int ct7 = 0;
    int ct8 = 0;
    for (int i = 0; i < arr.count; i++) {
        NSString *cur = [arr objectAtIndex:i];
        if ([cur intValue]==ECLivenessEYE) {
            ct1++;
        }else if ([cur intValue]==ECLivenessMOU){
            ct2++;
        }
        else if ([cur intValue]==ECLivenessYAW){
            ct7++;
        }
        else if ([cur intValue]==ECLivenessNOD){
            ct8++;
        }
        
    }
    if (ct1 >1 || ct2 >1 || ct7 > 1 || ct8 >1) {
        return YES;
    }
    
    return NO;
}


- (void)dealloc
{
    _xmlStr = nil;
    _xmlParse = nil;
    _mutDic = nil;
    _curVale = nil;
    //NSLog(@"ECXMLConfig dealloc");
}

@end
