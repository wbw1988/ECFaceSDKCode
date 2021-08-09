//
//  ECFaceViewController.m
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/13.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import "ECFaceViewController.h"
#import "ECAudioPlayer.h"
#import "ECLiveConfig.h"
#import "ECFaceDetecter.h"
#import "ECCameraManager.h"
#import "ECCoverView.h"
#import "ECImageUtil.h"
#import "ECMasonry.h"
#import "AppDelegate.h"

#define EC_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define EC_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ECFaceViewController ()

@property (nonatomic,strong)ECCoverView *coverUI;           //UI界面
@property (nonatomic,strong)ECFaceDetecter *faceDetecter;   //人脸检测器
@property (nonatomic,strong)ECCameraManager *cameraManager; //摄像头管理
@property (nonatomic,strong)NSArray *liveTypeArr;           //检活动作
@property (nonatomic,assign)CGFloat brightness; //屏幕亮度；

@property (nonatomic,assign)ECLiveState lastLiveState; //记录上一个动作的状态,如果相同,不处理

// 用来记录屏幕旋转方向
@property (nonatomic,assign)UIDeviceOrientation originOrientation;

@end

@implementation ECFaceViewController

#pragma mark ----- 系统方法 -----
// 不支持屏幕自动旋转
- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.brightness = [UIScreen mainScreen].brightness;
    [UIScreen mainScreen].brightness = 0.9f;
    
    

    if ([ECLiveConfig share].liveOrientation == ECLiveOrientationPortrait)
    {
        // 如果传入的是固定值,那么不支持自动旋转
        self.originOrientation = UIDeviceOrientationPortrait;
    }
    else if ([ECLiveConfig share].liveOrientation == ECLiveOrientationLeft)
    {
        self.originOrientation = UIDeviceOrientationLandscapeLeft;
    }
    else if ([ECLiveConfig share].liveOrientation == ECLiveOrientationRight)
    {
        self.originOrientation = UIDeviceOrientationLandscapeRight;
    }
    else
    {
        ///viewDidLoad添加监听屏幕旋转的方法
        self.originOrientation = UIDeviceOrientationPortrait;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    ///布局页面(初始化ECCoverViewUI, ECFaceDetecter, 初始化摄像头)
    [self initBaseUIAndSet];
    
    //参数配置
    [ECAudioPlayer share].bOn = [ECLiveConfig share].isAudio;
        
    
    ///动作处理，内部随机，如果外部不配置，则内部随意第一个为眨眼
    if ([ECLiveConfig share].liveTypeArr.count == 0) {
        NSArray *allArr = @[@(ECLivenessEYE),@(ECLivenessMOU),@(ECLivenessNOD),@(ECLivenessYAW)];
        NSArray *noEyeArr = @[@(ECLivenessMOU),@(ECLivenessNOD),@(ECLivenessYAW)];
        allArr = [self arrSortRandom:allArr];
        noEyeArr = [self arrSortRandom:noEyeArr];
        if ([ECLiveConfig share].action==0) {
            self.liveTypeArr = @[];
        }else if ([ECLiveConfig share].action==1) {
            //self.liveTypeArr = @[allArr[0]];
            self.liveTypeArr = @[@(ECLivenessEYE)];
        }else if ([ECLiveConfig share].action==2) {
            self.liveTypeArr = @[@(ECLivenessEYE),noEyeArr[0]];
        }else if ([ECLiveConfig share].action==3) {
            self.liveTypeArr = @[@(ECLivenessEYE),noEyeArr[0],noEyeArr[1]];
        }else if ([ECLiveConfig share].action==4) {
            self.liveTypeArr = @[@(ECLivenessEYE),noEyeArr[0],noEyeArr[1],noEyeArr[2]];
        }else{
            self.liveTypeArr = @[@(ECLivenessEYE),noEyeArr[0]];
        }
    }else{
        //按外部配置动作
        self.liveTypeArr = [ECLiveConfig share].liveTypeArr;
    }
    
    
    //相机权限判断
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus==AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted==NO) {
                    //无权限
                    [self sendCameraNotAuthMessage];
                }else{
                    // 开始检活
                    [self startFaceLiveCheck];
                }
            });
        }];
    }
    else if (authStatus==AVAuthorizationStatusAuthorized) {
        //有权限了
        [self startFaceLiveCheck];
    }else{
        //无权限
        [self sendCameraNotAuthMessage];
    }
    
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications)
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    
    
    
}

/**
 1.viewDidLoad添加监听屏幕旋转的方法
 2.实现OrientationDidChange屏幕旋转
 3.dealloc中移除通知
 */
- (void)OrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self updateCoverUIWithOrientation:orientation];
}

#pragma mark ----- 获取SDK信息 -----
+ (NSDictionary *)sdkInfo{
    return [ECFaceDetecter sdkInfo];
}

#pragma mark ----- 布局页面(初始化ECCoverViewUI, ECFaceDetecter, 初始化摄像头) -----
- (void)initBaseUIAndSet {
    //UI
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect fRect = self.view.frame;
    if (@available(iOS 11.0, *)) {
        CGFloat a =  [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        if (a >0) {
            //fRect.origin.y += 20;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    self.coverUI = [[ECCoverView alloc]initWithFrame:fRect];
    self.coverUI.delegate = self;
    self.coverUI.stateLB.text = [ECLiveConfig share].willStartMsg;
    //判断授权信息，如果是测试版本增加页面提示
    NSDictionary *authInfo = [ECFaceDetecter sdkInfo];
    NSArray *licArr = [authInfo objectForKey:@"sdk_license"];
    if (licArr.count <1) {
        return;
    }
    BOOL bAuth = NO;
    NSString *licTime = @"";
    for (NSString *str in licArr) {
        if ([str containsString:@"Permanent"]) {
            bAuth = YES;
            break;
        }
        
        if ([str hasPrefix:@"LicenseTime"]) {
            licTime = [[str componentsSeparatedByString:@" "] objectAtIndex:1];
        }
    }
    
    if (bAuth == YES)
    {
        self.coverUI.tipsLB.hidden = YES;
    }
    else
    {
        self.coverUI.tipsLB.hidden = NO;
        self.coverUI.tipsLB.text = [NSString stringWithFormat:@"测试版，到期：%@",licTime];
    }
    
    [self.view addSubview:self.coverUI];
    [self.coverUI ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(weakSelf.view);
    }];
    self.coverUI.backImgView.layer.bounds = self.coverUI.bounds;
    
    NSBundle *sdkBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[ECLiveConfig share].sdkBundleName ofType:nil]];
    NSString *datPath = [sdkBundle pathForResource:@"model2020.dat" ofType:nil];
    NSString *licPath = [sdkBundle pathForResource:@"EyeCoolLive.lic" ofType:nil];
    
    AVCaptureVideoOrientation videoOrientation;
    if (self.originOrientation == UIDeviceOrientationPortrait)
    {
        // 竖屏情况下,宽*高=480*640
        self.faceDetecter = [[ECFaceDetecter alloc]initWithDat:datPath license:licPath imgWidth:480 imgHeight:640];
        NSLog(@"datPath:%@ licPath:%@",datPath,licPath);
        videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    else
    {
        // 横屏情况下,宽*高=640*480
        self.faceDetecter = [[ECFaceDetecter alloc]initWithDat:datPath license:licPath imgWidth:640 imgHeight:480];
        NSLog(@"datPath:%@ licPath:%@",datPath,licPath);
        if (self.originOrientation == UIDeviceOrientationLandscapeLeft)
        {
            [self rotateToLeft];
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        else {
            [self rotateToRight];
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
    self.faceDetecter.delegate = self;
    
    //Camera
    AVCaptureDevicePosition deviPosi = AVCaptureDevicePositionFront;
    if ([ECLiveConfig share].deviceIdx == 1) {
        deviPosi = AVCaptureDevicePositionBack;
    }
    
    
    self.cameraManager = [[ECCameraManager alloc]initWithVideoOrientation:videoOrientation cameraPosition:deviPosi sessionPreset:AVCaptureSessionPreset640x480];
    _cameraManager.delegate = self;
    BOOL bCamera = [_cameraManager openCameraWithVideoConnection:videoOrientation];
    if (!bCamera) {
        return ;
    }
    [_cameraManager showPreviewOnLayer:_coverUI.liveView.layer frame:_coverUI.liveFrame];
    
    
}



#pragma mark ----- 关闭按钮方法 -----
- (void)didClickECCoverViewCloseBtn{
    [_faceDetecter stopLiveDetect];
    [self closePageSet];
}

//关闭卸载
- (void)closePageSet{
    
    if (_faceDetecter) {
        _faceDetecter = nil;
    }
    
    if (_cameraManager) {
        [_cameraManager stopBuffer];
        [_cameraManager closeCamera];
        _cameraManager = nil;
    }
    
    _coverUI = nil;

}


#pragma mark  ----- 屏幕旋转相关 -----
// 根据屏幕旋转程度更新UI
- (void)updateCoverUIWithOrientation:(UIDeviceOrientation)orientation
{
    
    // 修改UI
    __weak typeof(self) weakSelf = self;
    switch (orientation){
        // 向左
        case UIDeviceOrientationLandscapeLeft:
        {
            self.cameraManager.theVideoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            if (self.originOrientation == UIDeviceOrientationPortrait)
            {
                // 从垂直 -> 向左旋转
                //NSLog(@"屏幕从垂直 -> 向左旋转");
                [UIView animateWithDuration:0.75 animations:^{
                    [weakSelf rotateToLeft];
                    // 更新父视图UI
                    [weakSelf.coverUI.superview layoutIfNeeded];
                }];
            }
        }
            break;
            
        case UIDeviceOrientationLandscapeRight:
        {
            self.cameraManager.theVideoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            if (self.originOrientation == UIDeviceOrientationPortrait)
            {
                // 从垂直 -> 向右旋转
                //NSLog(@"屏幕从垂直 -> 向右旋转");
                [UIView animateWithDuration:0.75 animations:^{
                    [weakSelf rotateToRight];
                    // 更新父视图UI
                    [weakSelf.coverUI.superview layoutIfNeeded];
                }];
            }
        }
            break;
            
        case UIDeviceOrientationPortrait:
        {
            self.cameraManager.theVideoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
            // 修改UI
            //NSLog(@"屏幕从向左/右旋转 -> 垂直");
            [UIView animateWithDuration:0.75 animations:^{
                [weakSelf rotateToPortrait];
                // 更新父视图UI
                [weakSelf.coverUI.superview layoutIfNeeded];
            }];
        }
            break;
            
        default:
        {
            NSLog(@"默认状态");
        }
            break;
    }
    
    //SSAlg
    [self.faceDetecter stopEngin];
    self.faceDetecter = nil;
    NSBundle *sdkBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[ECLiveConfig share].sdkBundleName ofType:nil]];
    NSString *datPath = [sdkBundle pathForResource:@"model2020.dat" ofType:nil];
    NSString *licPath = [sdkBundle pathForResource:@"EyeCoolLive.lic" ofType:nil];
    if (self.originOrientation == UIDeviceOrientationPortrait)
    {
        // 初始化人脸检活算法
        // 竖屏情况下,宽*高=480*640
        self.faceDetecter = [[ECFaceDetecter alloc]initWithDat:datPath license:licPath imgWidth:480 imgHeight:640];
    }
    else
    {
        // 初始化人脸检活算法
        // 横屏情况下,宽*高=640*480
        self.faceDetecter = [[ECFaceDetecter alloc]initWithDat:datPath license:licPath imgWidth:640 imgHeight:480];
    }
    self.faceDetecter.orientation = self.originOrientation;
    self.faceDetecter.delegate = self;
    
    //开始进行活体检测(检测动作，时间配置)
    [self startFaceLiveCheck];
}

- (void)rotateToLeft
{
    [self.coverUI.liveView ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.top.equalTo(self.coverUI);
        make.right.equalTo(self.coverUI).offset(-15);
        make.width.height.ECMas_equalTo(EC_SCREEN_WIDTH);
    }];
    self.coverUI.detailView.transform = CGAffineTransformMakeRotation(M_PI_2);
    // 关闭按钮
    [self.coverUI.closeBtn ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.top.equalTo(self.view).offset(40);
        make.right.equalTo(self.view.ECMas_right).offset(-20);
        make.width.height.ECMas_equalTo(30);
    }];
    // 时间进度条
    [self.coverUI.progressView ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.bottom.equalTo(self.view.ECMas_bottom).offset(-20);
        make.right.equalTo(self.coverUI.closeBtn);
        make.width.height.ECMas_equalTo(38);
    }];
    self.coverUI.progressView.transform = CGAffineTransformMakeRotation(M_PI_2);
    //完成后更新当前检测到的页面状态
    self.originOrientation = UIDeviceOrientationLandscapeLeft;
}

- (void)rotateToRight
{
    [self.coverUI.liveView ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.top.equalTo(self.coverUI);
        make.right.equalTo(self.coverUI).offset(-15);
        make.width.height.ECMas_equalTo(EC_SCREEN_WIDTH);
    }];
    self.coverUI.detailView
    .transform = CGAffineTransformMakeRotation(-M_PI_2);
    // 关闭按钮
    [self.coverUI.closeBtn ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.bottom.equalTo(self.view.ECMas_bottom).offset(-20);
        make.left.equalTo(self.view).offset(20);
        make.width.height.ECMas_equalTo(38);
    }];
    // 时间进度条
    [self.coverUI.progressView ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.top.equalTo(self.view).offset(40);
        make.left.equalTo(self.coverUI.closeBtn);
        make.width.height.ECMas_equalTo(38);
    }];
    self.coverUI.progressView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    //完成后更新当前检测到的页面状态
    self.originOrientation = UIDeviceOrientationLandscapeRight;
}

- (void)rotateToPortrait
{
    [self.coverUI.liveView ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.top.centerX.equalTo(self.coverUI);
        make.width.height.ECMas_equalTo(EC_SCREEN_WIDTH);
    }];
    self.coverUI.detailView
    .transform = CGAffineTransformMakeRotation(0);
    // 关闭按钮
    [self.coverUI.closeBtn ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.left.equalTo(self.coverUI).offset(20);
        make.height.width.ECMas_equalTo(30);
        make.top.equalTo(self.coverUI.liveView).offset(50);
    }];
    // 时间进度条
    [self.coverUI.progressView ECMas_remakeConstraints:^(ECMasConstraintMaker *make) {
        make.right.equalTo(self.coverUI).offset(-20);
        make.height.width.ECMas_equalTo(38);
        make.top.equalTo(self.coverUI.closeBtn);
    }];
    self.coverUI.progressView.transform = CGAffineTransformMakeRotation(0);
    //完成后更新当前检测到的页面状态
    self.originOrientation = UIDeviceOrientationPortrait;
}

#pragma mark ----- ECFaceDetecter检活相关方法 -----
// 开始检活
- (void)startFaceLiveCheck {
    [_cameraManager startBuffer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // ECFaceDetecter开始进行活体检测(检测动作，时间配置)
        [self.faceDetecter startLiveDetect];
    });
}

// 发送相机权限问题回调
- (void)sendCameraNotAuthMessage
{
    // 置空
    [self closePageSet];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(faceLivenessFailedWithError:liveType:)]) {
                [self.delegate faceLivenessFailedWithError:ECLivenessErrorCameraNotAuth liveType:0];
            }
            
        }];
    });
}

// 根据检活状态播放对应检活语音
- (void)playVideoFromLiveType:(ECLiveType )alive
{
    switch (alive) {
        case ECLiveEYE:
            [[ECAudioPlayer share] playAudio:ECAudioBlinkEyes];
            break;
        case ECLiveMOU:
            [[ECAudioPlayer share] playAudio:ECAudioOpenMouth];
            break;
        case ECLiveYAW:
            [[ECAudioPlayer share] playAudio:ECAudioYawHead];
            break;
        case ECLiveNOD:
            [[ECAudioPlayer share] playAudio:ECAudioNodHead];
            break;
        default:
            break;
    }
}

// 获取检活文本信息
-(NSString *)liveMsgFromLiveType:(ECLiveType )alive
{
    NSString *msg = @"";
    switch (alive) {
        case ECLiveEYE:
            msg = [ECLiveConfig share].pleaseBlinkEyes;
            break;
        case ECLiveMOU:
            msg = [ECLiveConfig share].pleaseOpenMouth;
            break;
        case ECLiveYAW:
            msg = [ECLiveConfig share].pleaseTurnHead;
            break;
        case ECLiveNOD:
            msg = [ECLiveConfig share].pleaseNodHead;
            break;
        case ECLiveLOOK:
            msg = [ECLiveConfig share].pleaseLookCamera;
            break;
        default:
            break;
    }
    return msg;
}

// 检活动作数组随机排序
- (NSArray *)arrSortRandom:(NSArray *)arr{
    NSArray *sortArr = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [str1 compare:str2];
        } else {
            return [str2 compare:str1];
        }
    }];
    return sortArr;
}


#pragma mark ----- 检测器代理回调 -----

#pragma mark - ======== 人脸识别检活成功回调 ========
//成功回调
- (void)ECFaceLiveCheckSuccessGetImage:(NSArray *)imgArr{
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;
    
//    if (self.originOrientation == UIDeviceOrientationLandscapeLeft || self.originOrientation == UIDeviceOrientationLandscapeRight || self.originOrientation == UIDeviceOrientationUnknown)
//    {
//        [self rotateToPortrait];
//    }
    
    [UIScreen mainScreen].brightness = self.brightness;

    __weak typeof(self) weakSelf = self;
    [self closePageSet];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(faceLivenessSuccessWithImg:liveArr:)]) {
            [self.delegate faceLivenessSuccessWithImg:imgArr liveArr:weakSelf.liveTypeArr];
        }
    }];
    

}

#pragma mark - ======== 人脸识别检测错误回调 ========
//检测错误
- (void)ECFaceDetecterWithError:(ECDetectError )aErr liveType:(ECLiveType)alive{
    NSString *msg;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;
//    if (self.originOrientation == UIDeviceOrientationLandscapeLeft || self.originOrientation == UIDeviceOrientationLandscapeRight || self.originOrientation == UIDeviceOrientationUnknown)
//    {
//        [self rotateToPortrait];
//    }
    //NSLog(@"%d %d",aErr,alive);
    switch (aErr) {
        case ECDetectErrorDuckDatNotExist:
            msg = @"模型文件不存在";
            break;
        case ECDetectErrorDuckLicNotExist:
            msg = @"授权文件不存在";
            break;
        case ECDetectErrorDuckExpiration:
            msg = @"时间版，授权过期";
            break;
        case ECDetectErrorDuckNotMatch:
            msg = @"包名绑定不一致";
            break;
        case ECDetectErrorDuckInitOther:
            msg = @"算法初始化错误";
            break;
        case ECDetectErrorLiveCheckCancel:
            msg = @"检活取消了";
            break;
        case ECDetectErrorTimeOutNoFace:
            msg = @"超时，未检测到人脸";
            [self.coverUI.progressView setProgress:1.0f animated:NO];
            break;
        case ECDetectErrorTimeOutNoPass:
            msg = @"超时，动作未通过";
            [self.coverUI.progressView setProgress:1.0f animated:NO];
            break;
        case ECDetectErrorCurrentFaceLost:
            msg = @"丢帧检测，中突换人";
            [self.coverUI.progressView setProgress:1.0f animated:NO];
            break;
        case ECDetectErrorNotLiveFace:
            msg = @"活体检测失败";
            [self.coverUI.progressView setProgress:1.0f animated:NO];
            break;
        default:
            break;
    }

    [self closePageSet];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(faceLivenessFailedWithError:liveType:)]) {
            [self.delegate faceLivenessFailedWithError:(ECLivenessError)aErr liveType:(ECLivenessType)alive];
        }
    }];
    
    [UIScreen mainScreen].brightness = self.brightness;

    
}

#pragma mark - ======== 人脸检活过程中状态回调 ========
//检活过程中状态回调
- (void)ECFaceLiveState:(ECLiveState)liveState liveType:(ECLiveType)alive{
    NSString *msg;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;

    switch (liveState) {
        case ECLiveStateFaceNormal:
            //NSLog(@"人脸检测正常,状态:%d",liveState);
            msg = @"人脸检测正常";
            if (self.liveTypeArr.count > 0)
            {
                self.coverUI.stateLB.text = [self liveMsgFromLiveType:alive];
            }
            else
            {
                
            }
            
            [_coverUI setFaceInUI];
            break;
        case ECLiveStateFaceLeave:
            //NSLog(@"人脸离开,状态:%d",liveState);
            msg = @"人脸离开";
            self.coverUI.stateLB.text = [ECLiveConfig share].pleaseFaceIn;
            [_coverUI setFaceOutUI];
            break;
        case ECLiveStateFaceShake:
            //NSLog(@"人脸晃动,状态:%d",liveState);
            msg = @"人脸晃动";
            //[_coverUI setFaceOutUI];
            self.coverUI.stateLB.text = [ECLiveConfig share].pleaseNoShake;
            break;
        case ECLiveStateFaceFar:
            //NSLog(@"人脸太远,状态:%d",liveState);
            msg = @"人脸太远";
            self.coverUI.stateLB.text = [ECLiveConfig share].pleaseClosely;
            [[ECAudioPlayer share] playAudio:ECAudioClosely];
            [_coverUI setFaceOutUI];
            break;
        case ECLiveStateFaceClose:
            //NSLog(@"人脸太近,状态:%d",liveState);
            msg = @"人脸太近";
            self.coverUI.stateLB.text = [ECLiveConfig share].pleaseFarAwy;
            [[ECAudioPlayer share] playAudio:ECAudioFarAway];
            [_coverUI setFaceOutUI];
            break;
        case ECLiveStateNotLookCamera:
            //NSLog(@"人脸未直视摄像头,上次保存状态self.lastLiveState:%d 最新状态:%d",self.lastLiveState,liveState);
            if (self.lastLiveState == liveState)
            {
                
            }
            else
            {
                self.coverUI.stateLB.text = [ECLiveConfig share].pleaseFocusCamera;
                self.lastLiveState = liveState;
            }
            
            [_coverUI setFaceOutUI];
            break;
        case ECLiveStateFaceHasCover:
            self.coverUI.stateLB.text = [ECLiveConfig share].pleaseNotCoverFace;
            [_coverUI setFaceOutUI];
            break;
        case ECLiveStateFaceHackNoPass:
            self.coverUI.stateLB.text = @"检测到假体";
            [_coverUI setFaceOutUI];
            break;
        default:
            break;
    }
    //NSLog(@"状态：%d %@",liveState,msg);

}

#pragma mark - ======== 检测某个动作的倒计时，还剩下多长时间时间,单位秒 ========
//检测某个动作的倒计时，还剩下多长时间时间,单位秒
- (void)ECFaceCheckOneLive:(ECLiveType )alive leftTime:(int)leftTime{
    //NSLog(@"计时：%d %d",alive,leftTime);
    self.coverUI.progressView.progressLabel.text = [NSString stringWithFormat:@"%d",leftTime];
    [self.coverUI.progressView setProgress:(self.coverUI.progressView.progress+(1.0f/[ECLiveConfig share].timeOut)) animated:YES];
}


#pragma mark - ======== 将要开始进行某个动作检活 ========
//将要开始进行某个动作检活
- (void)ECFaceLiveWillStartCheck:(ECLiveType )alive{
    //NSLog(@"将要开始检测：%d",alive);
    //NSLog(@"timeOut:%d",[ECLiveConfig share].timeOut);
    self.coverUI.progressView.progressLabel.text = [NSString stringWithFormat:@"%d",[ECLiveConfig share].timeOut];
    [self.coverUI.progressView setProgress:0 animated:NO];

    [self playVideoFromLiveType:alive];
    NSString *msg = [self liveMsgFromLiveType:alive];
    self.coverUI.stateLB.text = msg;
    [_coverUI setFaceInUI];
    [_coverUI playFaceAnimation:alive];

    
}

#pragma mark - ======== 结束某个动作检测 ========
//结束某个动作检测
- (void)ECFaceLiveDidCompleteCheck:(ECLiveType )alive{
    //NSLog(@"结束检测：%d",alive);
    [[ECAudioPlayer share] playAudio:ECAudioGood];
    [_coverUI stopFaceAnimation];
}

#pragma mark - ======== 使用代理方法返回设置的检活动作 ========
///检活动作组合(使用代理设置检测动作数组)
- (NSArray *)ECFaceLiveCheckSequence{
    if ([ECLiveConfig share].onlyFocus) {
        return [NSArray array];
    }
    return self.liveTypeArr;
    
}

#pragma mark - ======== 使用代理方法返回设置的检测时间 ========
///检活单个动作的超时时间(使用代理设置检测时间)
- (int)ECFaceLiveOneActionTime{
    return [ECLiveConfig share].timeOut;
}


#pragma mark ----- 相机代理回调 ------
// 相机视频流回调
- (void)cameraDidOutputBuffer:(CMSampleBufferRef )sampleBuffer
{
    //NSLog(@"视频流回调屏幕旋转状态:%ld",self.originOrientation);
    if (self.faceDetecter)
    {
        self.faceDetecter.orientation = self.originOrientation;
        [self.faceDetecter pushDetectBuffer:sampleBuffer orientation:self.originOrientation];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault; //白色
}

#pragma mark ----- 系统方法 dealloc -----
- (void)dealloc
{
    _coverUI = nil;
    _faceDetecter = nil;
    _cameraManager = nil;
    _liveTypeArr = nil;
    [ECAudioPlayer destory];
    //NSLog(@"ECFaceViewController dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //[[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
}

@end
