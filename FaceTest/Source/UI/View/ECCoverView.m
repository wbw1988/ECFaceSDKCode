//
//  ECCoverView.m
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/13.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import "ECCoverView.h"
#import "ECLiveConfig.h"
#import "ECAudioPlayer.h"
#import "ECMasonry.h"

#define  ECConverItemLen  ([UIScreen mainScreen].bounds.size.width*0.716)
//动画播放时间
#define LIVE_ACTION_ANI_TIME 1.5f

#define EC_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define EC_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ECCoverView ()
@property (nonatomic , strong) NSArray *arrMouthImages; //张嘴动画序列
@property (nonatomic , strong) NSArray *arrYawImages;   //转头动画序列
@property (nonatomic , strong) NSArray *arrPitchImages; //上下点头动画序列
@property (nonatomic , strong) NSArray *arrBlinkImages; //眨眼动画序列


@end

@implementation ECCoverView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置 背景为clear
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = NO;
        
        
        __weak typeof(self) weakSelf = self;
        
        //视频区域
        self.liveView = [[UIView alloc]init];
        self.liveView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.liveView];
        [self.liveView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.top.centerX.equalTo(weakSelf);
            make.width.height.ECMas_equalTo(EC_SCREEN_WIDTH);
        }];

        //背景图
        self.backImgView = [[UIImageView alloc]init];
        self.backImgView.image = [self imageNamed:@"v2-faceOut@3x.png"];
        self.backImgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backImgView];
        [self.backImgView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.top.centerX.width.height.equalTo(weakSelf.liveView);
        }];
        
        // 详细信息
        self.detailView = [[UIView alloc]init];
        [self addSubview:self.detailView];
        [self.detailView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.centerX.equalTo(weakSelf.liveView);
            make.width.height.ECMas_equalTo(240);
            make.top.equalTo(weakSelf.liveView.ECMas_bottom);
        }];
        
        
        //动画部分
        CGFloat aniImgItemWid = 120;
        self.animationImgView = [[UIImageView alloc]init];
        self.animationImgView.backgroundColor = [UIColor clearColor];
        self.animationImgView.contentMode = UIViewContentModeScaleAspectFit;
        self.animationImgView.image = [self imageNamed:@"v2-faceLook@3x.png"];
        //_animationImgView.center = CGPointMake(self.center.x,_animationImgView.center.y);
        self.animationImgView.animationImages = nil;
        [self.detailView addSubview:self.animationImgView];
        [self.animationImgView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.centerX.top.equalTo(weakSelf.detailView);
            make.width.height.ECMas_equalTo(aniImgItemWid);
        }];
        
        //序列动画的照片
        UIImage *normalFaceImg = [self imageNamed:@"v2-faceLook@3x.png"];
        UIImage *turnLeftFaceImg = [self imageNamed:@"v2-faceLeft@3x.png"];
        UIImage *turnRightFaceImg = [self imageNamed:@"v2-faceRight@3x.png"];
        UIImage *blikFaceImg = [self imageNamed:@"v2-faceEye@3x.png"];
        UIImage *nodDownFaceImg = [self imageNamed:@"v2-faceDown@3x.png"];
        UIImage *nodUpFaceImg = [self imageNamed:@"v2-faceUp@3x.png"];
        UIImage *mouthFaceImg = [self imageNamed:@"v2-faceMou@3x.png"];
        self.arrMouthImages = @[normalFaceImg,mouthFaceImg];
        self.arrBlinkImages = @[normalFaceImg,blikFaceImg];
        self.arrPitchImages = @[normalFaceImg,nodUpFaceImg,normalFaceImg,nodDownFaceImg];
        self.arrYawImages = @[normalFaceImg,turnLeftFaceImg,normalFaceImg,turnRightFaceImg];
        
        
        //文字
        CGFloat marginBottom = CGRectGetMaxY(_animationImgView.frame);
        marginBottom += 25;
        self.stateLB = [[UILabel alloc]init];
        self.stateLB.text = [ECLiveConfig share].pleaseFaceIn;
        self.stateLB.backgroundColor = [UIColor clearColor];
        self.stateLB.textAlignment = NSTextAlignmentCenter;
        self.stateLB.font = [UIFont boldSystemFontOfSize:20];
        self.stateLB.textColor = [UIColor colorWithRed:12/255.0 green:56/255.0 blue:103/255.0 alpha:1];
        [self.detailView addSubview:self.stateLB];
        [self.stateLB ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.centerX.equalTo(weakSelf.detailView);
            make.height.ECMas_equalTo(30);
            make.width.ECMas_equalTo(170);
            make.top.equalTo(weakSelf.animationImgView.ECMas_bottom).offset(25);
        }];
        
        // 显示license到期时间
        self.tipsLB = [[UILabel alloc]init];
        self.tipsLB.textColor = [UIColor whiteColor];
        self.tipsLB.backgroundColor = [UIColor lightGrayColor];
        self.tipsLB.textAlignment = NSTextAlignmentCenter;
        self.tipsLB.clipsToBounds = YES;
        self.tipsLB.layer.cornerRadius = 20;
        self.tipsLB.numberOfLines = 0;
        self.tipsLB.hidden = YES;
        self.tipsLB.font = [UIFont systemFontOfSize:15];
        [self.detailView addSubview:self.tipsLB];
        [self.tipsLB ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.bottom.centerX.equalTo(weakSelf.detailView);
            make.height.ECMas_equalTo(40);
            make.width.ECMas_equalTo(240);
        }];
        
        //关闭按钮
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat marginTop = 36;
        if (@available(iOS 11.0, *)) {
            CGFloat a =  [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
            if (a >0) {
                marginTop += 15;
            }
        }
//        self.closeBtn.frame = CGRectMake(17, marginTop, 30, 30);
        [self.closeBtn setTintColor:[UIColor colorWithRed:34/255.0 green:199/255.0 blue:252/255.0 alpha:1]];
        [self.closeBtn setImage:[self imageNamed:@"v2-close@3x.png"] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
        [self.closeBtn ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.left.equalTo(weakSelf).offset(20);
            make.height.width.ECMas_equalTo(30);
            make.top.equalTo(weakSelf.liveView).offset(50);
        }];
        
        
        //倒计时
        CGFloat daAcItemWith = 38.0f;
        self.progressView = [[ECDALabeledCircularProgressView alloc]initWithFrame:CGRectMake(self.bounds.size.width - daAcItemWith - 17,marginTop, daAcItemWith, daAcItemWith)];
        self.progressView.roundedCorners = YES;
        self.progressView.progressTintColor = [UIColor colorWithRed:43/255.0 green:115/255.0 blue:234/255.0 alpha:1];
        self.progressView.progressLabel.textColor = [UIColor colorWithRed:43/255.0 green:115/255.0 blue:234/255.0 alpha:1];
        self.progressView.thicknessRatio = 0.15f;
        self.progressView.progressLabel.font = [UIFont systemFontOfSize:22.0f];
        self.progressView.trackTintColor = [UIColor colorWithRed:228/255.0 green:234/255.0 blue:254/255.0 alpha:1];
        self.progressView.hidden = NO;
        [self addSubview:self.progressView];
        [self.progressView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.right.equalTo(weakSelf).offset(-20);
            make.height.width.ECMas_equalTo(38);
            make.top.equalTo(weakSelf.closeBtn);
        }];
        
        /*
        //声音按钮
        UIImageView *voiceIMG = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 60,self.bounds.size.width+20, 38, 38)];
        voiceIMG.tag = 1038;
        voiceIMG.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doVoiceBtnControl)];
        [voiceIMG addGestureRecognizer:tapGest];
        if ([ECLiveConfig share].isAudio) {
            voiceIMG.image = [self imageNamed:@"ecvolume_on@2x.png"];
        }else
        {
            voiceIMG.image = [self imageNamed:@"ecvolume_off@2x.png"];
        }
        [self addSubview:voiceIMG];
        marginBottom +=30;
         */

        
        
    }
    return self;
}

//设置人脸丢失和离开的切换边框图
- (void)setFaceInUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backImgView.image = [self imageNamed:@"v2-faceIn@3x.png"];
    });
}

//设置人脸丢失和离开的切换边框图
- (void)setFaceOutUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backImgView.image = [self imageNamed:@"v2-faceOut@3x.png"];
    });
}

//播放人脸动作动画
- (void)playFaceAnimation:(int )type{
    
    switch (type) {
        case 1:
            if (![self.animationImgView isAnimating]) {
                self.animationImgView.animationDuration = LIVE_ACTION_ANI_TIME;
                self.animationImgView.animationImages = self.arrBlinkImages;
                [self.animationImgView startAnimating];
            }
            break;
        case 2:
            if (![self.animationImgView isAnimating]) {
                self.animationImgView.animationDuration = LIVE_ACTION_ANI_TIME;
                self.animationImgView.animationImages = self.arrMouthImages;
                [self.animationImgView startAnimating];
            }
            break;
        case 7:
            if (![self.animationImgView isAnimating]) {
                self.animationImgView.animationDuration = LIVE_ACTION_ANI_TIME;
                self.animationImgView.animationImages = self.arrYawImages;
                [self.animationImgView startAnimating];
            }
            break;
        case 8:
            if (![self.animationImgView isAnimating]) {
                self.animationImgView.animationDuration = LIVE_ACTION_ANI_TIME;
                self.animationImgView.animationImages = self.arrPitchImages;
                [self.animationImgView startAnimating];
            }
            break;
        default:
            [self stopFaceAnimation];
            break;
    }
    
}

//强制停止播放任何动作动画
- (void)stopFaceAnimation{
    if ([self.animationImgView isAnimating]) {
        [self.animationImgView stopAnimating];
    }
    self.animationImgView.animationImages = nil;
}


//视频预览区域
- (CGRect)liveFrame{
    CGRect myRect = CGRectMake((self.bounds.size.width - ECConverItemLen )/2.0f,(self.bounds.size.width - ECConverItemLen )/2.0f, ECConverItemLen , ECConverItemLen);
    return myRect;
}

#pragma mark private api

- (void)doVoiceBtnControl{
    UIImageView *voiceIMG =(UIImageView *)[self viewWithTag:1038];
    [ECLiveConfig share].isAudio = ![ECLiveConfig share].isAudio;
    [ECAudioPlayer share].bOn = [ECLiveConfig share].isAudio;
    if ([ECLiveConfig share].isAudio) {
        voiceIMG.image = [self imageNamed:@"ecvolume_on@2x.png"];
    }else
    {
        voiceIMG.image = [self imageNamed:@"ecvolume_off@2x.png"];
        [[ECAudioPlayer share] forceStop];
    }
    
}


- (void)closeBtnAction{
    _liveView = nil;
    _stateLB = nil;
    _progressView = nil;
    if ([self.delegate respondsToSelector:@selector(didClickECCoverViewCloseBtn)]) {
        [self.delegate didClickECCoverViewCloseBtn];
    }
}

- (UIImage *)imageNamed:(NSString *)fName{
    NSBundle *sdkBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[ECLiveConfig share].sdkBundleName ofType:nil]];
    NSString *imgPath = [sdkBundle pathForResource:fName ofType:nil];
    return [UIImage imageWithContentsOfFile:imgPath];
}

- (void)dealloc
{
    _liveView = nil;
    _stateLB = nil;
    _progressView = nil;
    //NSLog(@"FaceCover dealloc");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
