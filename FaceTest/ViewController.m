//
//  ViewController.m
//  ECFaceApp
//
//  Created by eyecool on 2020/7/2.
//  Copyright © 2020 eyecool. All rights reserved.
//

#import "ViewController.h"
#import "ECFaceViewController.h"
#import "ECLiveConfig.h"
#import "ECXMLConfig.h"
#import "ECMasonry.h"
#import "ResultViewController.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"




@interface ViewController ()<ECFaceLivenessDelegate>

// eyecool logo
@property (nonatomic , strong) UIImageView * logoImageView;
// eyecool face image
@property (nonatomic , strong) UIImageView * faceImageView;
// eyecool 开始检测按钮
@property (nonatomic , strong) UIButton * startButton;
// eyecool SDK配置按钮
@property (nonatomic , strong) UIButton * profileButton;

@end

@implementation ViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 布局所有子视图
    [self layoutAllSubviews];
    
    NSDictionary *sdkInfo = [ECFaceViewController sdkInfo];
    NSLog(@"sdkinfo: %@",sdkInfo);
    
    
    // Do any additional setup after loading the view.
}

// 布局所有子视图
- (void)layoutAllSubviews
{
    self.title = @"眼神SDK";
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    // logo
    self.logoImageView = [[UIImageView alloc]init];
    self.logoImageView.image = [UIImage imageNamed:@"demoLOGO"];
    [self.view addSubview:self.logoImageView];
    [self.logoImageView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.top.ECMas_equalTo(@90);
        make.centerX.equalTo(weakSelf.view);
        make.width.ECMas_equalTo(@237);
        make.height.ECMas_equalTo(@152);
    }];
    
    // face
    self.faceImageView = [[UIImageView alloc]init];
    self.faceImageView.image = [UIImage imageNamed:@"idx-face"];
    [self.view addSubview:self.faceImageView];
    [self.faceImageView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view);
        make.centerX.equalTo(weakSelf.view);
        make.width.ECMas_equalTo(@183);
        make.height.ECMas_equalTo(@208);
    }];
    
    // 开始检测按钮,进入检测界面
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startButton setTitle:@"开始检测" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont systemFontOfSize:22];
    self.startButton.backgroundColor = [UIColor colorWithRed:44.0/255.0 green:116.0/255.0 blue:234.0/255.0 alpha:1.0f];
    [self.startButton addTarget:self action:@selector(startButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    [self.startButton ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view.ECMas_bottom).offset(-100);
        make.centerX.equalTo(weakSelf.view);
        make.left.equalTo(weakSelf.view.ECMas_left).offset(20);
        make.height.ECMas_equalTo(@49);
    }];
    
    // 配置按钮,进入配置界面
    self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.profileButton setImage:[UIImage imageNamed:@"idx-nset"] forState:UIControlStateNormal];
    [self.profileButton addTarget:self action:@selector(profileButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.profileButton];
    [self.profileButton ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(90);
        make.right.equalTo(weakSelf.view.ECMas_right).offset(-12);
        make.width.height.ECMas_equalTo(@40);
    }];
}

- (void)profileButtonDidClicked:(UIButton *)sender
{
    ProfileViewController *profileVC = [[ProfileViewController alloc]init];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:43/255.0 green:115/255.0 blue:234/255.0 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:17]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)startButtonDidClicked:(UIButton *)sender
{
    //集成使用时开启下方参数
    /*
    //参数配置；默认参数，请在ECLiveConfig.m 配置
    //参数的说明请见开发文档，配置的参数如果不合要求，将按默认参数处理；
    NSString *defXML = @"<param><actionList>1278</actionList><actionOrder>1*</actionOrder><shakeDegree>20</shakeDegree><imgCompress>85</imgCompress><pupilDistMin>80</pupilDistMin><pupilDistMax>170</pupilDistMax><timeOut>15</timeOut><isAudio>1</isAudio><eyeDegree>8</eyeDegree><mouthDegree>8</mouthDegree><rawDegree>5</rawDegree><pitchDegree>4</pitchDegree><isLog>1</isLog><deviceIdx>0</deviceIdx></param>";
    [ECXMLConfig confFaceSDKFromXMLString:defXML];
    */
    
    // 获取到后端配置后
    //[ECLiveConfig share].eyeDegree = 配置;
    ECFaceViewController *faceVC = [[ECFaceViewController alloc]init];
    faceVC.delegate = self;
    if (@available(iOS 13.0, *)) {
        faceVC.modalInPresentation = YES;
        faceVC.modalPresentationStyle = UIModalPresentationFullScreen;
    } else {
        // Fallback on earlier versions
    }
    [self presentViewController:faceVC animated:YES completion:nil];
}

/**
 活体检测成功，
 imgArr: 成功采集的照片，每个动作采集一张；为UIImage数组
 liveArr: 检活过程之中做的动作；为ECLiveType数组
 */
- (void)faceLivenessSuccessWithImg:(NSArray *)imgArr liveArr:(NSArray *)liveArr
{
    
    NSLog(@"活检成功: %@ %@",imgArr,liveArr);
    
    //返回的数组里面，第一张照片为正脸照片，为了采集到质量更好的照片，建议将第一个动作设置为 眨眼检测
    NSData *imgData = UIImageJPEGRepresentation([imgArr objectAtIndex:0], [ECLiveConfig share].imgCompress/100.0f);
    //如果大于30K，循环压缩
    UIImage * oriImage = [UIImage imageWithData:imgData];
    CGFloat quality = [ECLiveConfig share].imgCompress / 100.0f * 0.7f;
    while (imgData.length >= 30*1024) {
        quality *=0.95;
        imgData = UIImageJPEGRepresentation(oriImage,quality);
    }
    
    //转换成b64上传
    NSString *b64 = [imgData base64EncodedStringWithOptions:0];
    //TODO：成功的逻辑，上传照片到服务器进行比对验证
    
    ResultViewController * resultVC = [[ResultViewController alloc]init];
    resultVC.isSuccess = YES;
    resultVC.errMsg = @"检活成功";
    resultVC.img = [imgArr objectAtIndex:0];
    [self presentViewController:resultVC animated:NO completion:nil];


}


/**
 活体检测失败
 aErr: 当前失败的错误码
 aLive: 失败时当前正在进行检测的动作，用于分析超时和未通过的动作
 */
- (void)faceLivenessFailedWithError:(ECLivenessError )aErr liveType:(ECLivenessType )aLive
{
    
    NSLog(@"活检失败: %d %d",aErr,aLive);
    //TODO: 失败的逻辑，界面提示等；
    
    NSString *errorMsg;
    switch (aErr) {
        case ECLivenessErrorDuckDatNotExist:
            errorMsg = @"模型文件不存在";
            break;
        case ECLivenessErrorDuckLicNotExist:
            errorMsg = @"授权文件不存在";
            break;
        case ECLivenessErrorDuckExpiration:
            errorMsg = @"授权过期";
            break;
        case ECLivenessErrorDuckNotMatch:
            errorMsg = @"授权包名不匹配";
            break;
        case ECLivenessErrorDuckInitOther:
            errorMsg = @"算法初始化失败";
            break;
        case ECLivenessErrorLiveCheckCancel:
            errorMsg = @"检活取消";
            break;
        case ECLivenessErrorTimeOutNoFace:
            errorMsg = @"超时，未检测到人脸";
            break;
        case ECLivenessErrorTimeOutNoPass:
            errorMsg = @"超时，未配合动作";
            break;
        case ECLivenessErrorCurrentFaceLost:
           errorMsg = @"人脸丢失，请重试";
            break;
        case ECLivenessErrorNotLiveFace:
            errorMsg = @"活体检测失败";
            break;
        case ECLivenessErrorCameraNotAuth:
            errorMsg = @"摄像头错误，请检查权限设置";
            break;
        
        default:
            errorMsg = @"检活失败，其他错误";
            break;
    }
    
    ResultViewController *resultVC = [[ResultViewController alloc]init];
    resultVC.isSuccess = NO;
    resultVC.errMsg = errorMsg;
    [self presentViewController:resultVC animated:NO completion:nil];
    
    
}



@end
