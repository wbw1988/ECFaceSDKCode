//
//  ProfileViewController.m
//  ECFaceApp
//
//  Created by eyecool on 2020/7/6.
//  Copyright © 2020 eyecool. All rights reserved.
//  配置控制器

#import "ProfileViewController.h"
#import "ECMasonry.h"
#import "ECLiveConfig.h"
#import "AppDelegate.h"

@interface ProfileViewController ()

// 超时时间label
@property (nonatomic , strong) UILabel * timeoutLabel;
@property (nonatomic , strong) UILabel * timeLabel;
// 超时时间Slider
@property (nonatomic , strong) UISlider * timeSlider;

// 动作个数label
@property (nonatomic , strong) UILabel * actionLabel;
// 动作个数控制
@property (nonatomic , strong) UISegmentedControl * actionControl;

// 屏幕旋转
@property (nonatomic , strong) UILabel * rotateLabel;
@property (nonatomic , strong) UISegmentedControl * rotateControl;

// 声音label
@property (nonatomic , strong) UILabel * soundLabel;
// 声音开关 on:开启 off:关闭 默认on
@property (nonatomic , strong) UISwitch * soundSwitch;

// 后置摄像头Label
@property (nonatomic , strong) UILabel *  backCameraLabel;
// 后置摄像头开关 on:开启 off:关闭 默认off
@property (nonatomic , strong) UISwitch * backCameraSwitch;

// 保存按钮
@property (nonatomic , strong) UIButton * saveButton;

@end

@implementation ProfileViewController

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 布局所有子视图
    [self layoutAllSubviews];
}

- (void)layoutAllSubviews
{
    __weak typeof(self) weakSelf = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"参数设置";
    
    self.timeoutLabel = [self createCommonLabelWithTitle:@"超时时间"];
    [self.view addSubview:self.timeoutLabel];
    [self.timeoutLabel ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(100);
        make.left.equalTo(weakSelf.view).offset(20);
        make.width.ECMas_equalTo(@82);
        make.height.ECMas_equalTo(@40);
    }];
    
    // 默认超时15秒
    self.timeLabel = [self createCommonLabelWithTitle:[NSString stringWithFormat:@"%d",[ECLiveConfig share].timeOut]];
    [self.view addSubview:self.timeLabel];
    [self.timeLabel ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.timeoutLabel);
        make.left.equalTo(weakSelf.timeoutLabel.ECMas_right).offset(5);
        make.width.height.ECMas_equalTo(@30);
    }];
    
    self.timeSlider = [[UISlider alloc]init];
    self.timeSlider.maximumValue = 30;
    self.timeSlider.minimumValue = 5;
    self.timeSlider.value = [ECLiveConfig share].timeOut;
    [self.timeSlider addTarget:self action:@selector(timeSliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.timeSlider];
    [self.timeSlider ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.timeoutLabel);
        make.left.equalTo(weakSelf.timeLabel.ECMas_right).offset(5);
        make.right.equalTo(weakSelf.view.ECMas_right).offset(-20);
        make.height.equalTo(weakSelf.timeoutLabel);
    }];
    
    self.actionLabel = [self createCommonLabelWithTitle:@"动作个数"];
    [self.view addSubview:self.actionLabel];
    [self.actionLabel ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.left.equalTo(weakSelf.timeoutLabel);
        make.top.equalTo(weakSelf.timeoutLabel.ECMas_bottom).offset(40);
        make.width.height.equalTo(weakSelf.timeoutLabel);
    }];
    
    self.actionControl = [[UISegmentedControl alloc] initWithItems:@[@"0",@"1",@"2",@"3",@"4"]];
    self.actionControl.selectedSegmentIndex = [ECLiveConfig share].action;
    [self.view addSubview:self.actionControl];
    [self.actionControl ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.left.equalTo(weakSelf.timeLabel.ECMas_right);
        make.right.equalTo(weakSelf.timeSlider);
        make.height.ECMas_equalTo(@30);
        make.centerY.equalTo(weakSelf.actionLabel);
    }];
    
    self.rotateLabel = [self createCommonLabelWithTitle:@"横屏检测"];
    [self.view addSubview:self.rotateLabel];
    [self.rotateLabel ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.left.equalTo(weakSelf.timeoutLabel);
        make.top.equalTo(weakSelf.actionLabel.ECMas_bottom).offset(40);
        make.width.height.equalTo(weakSelf.timeoutLabel);
    }];
    
    self.rotateControl = [[UISegmentedControl alloc] initWithItems:@[@"竖屏",@"左横屏",@"右横屏",@"旋转"]];
    self.rotateControl.selectedSegmentIndex = [ECLiveConfig share].liveOrientation;
    [self.view addSubview:self.rotateControl];
    [self.rotateControl ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.left.equalTo(weakSelf.timeLabel.ECMas_right);
        make.right.equalTo(weakSelf.timeSlider);
        make.height.ECMas_equalTo(@30);
        make.centerY.equalTo(weakSelf.rotateLabel);
    }];
    
    self.soundLabel = [self createCommonLabelWithTitle:@"开启语音"];
    [self.view addSubview:self.soundLabel];
    [self.soundLabel ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.left.equalTo(weakSelf.timeoutLabel);
        make.top.equalTo(weakSelf.rotateLabel.ECMas_bottom).offset(40);
        make.width.height.equalTo(weakSelf.timeoutLabel);
    }];
    
    self.soundSwitch = [[UISwitch alloc]init];
    self.soundSwitch.on = [ECLiveConfig share].isAudio;
    [self.view addSubview:self.soundSwitch];
    [self.soundSwitch ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.soundLabel);
        make.left.equalTo(weakSelf.timeLabel.ECMas_right);
        make.width.ECMas_equalTo(@70);
        make.height.ECMas_equalTo(@30);
    }];
    
    self.backCameraLabel = [self createCommonLabelWithTitle:@"后置摄像头"];
    [self.view addSubview:self.backCameraLabel];
    [self.backCameraLabel ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.left.equalTo(weakSelf.timeoutLabel);
        make.top.equalTo(weakSelf.soundLabel.ECMas_bottom).offset(40);
        make.width.height.equalTo(weakSelf.timeoutLabel);
    }];
    
    self.backCameraSwitch = [[UISwitch alloc]init];
    self.backCameraSwitch.on = [ECLiveConfig share].deviceIdx;
    [self.view addSubview:self.backCameraSwitch];
    [self.backCameraSwitch ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.backCameraLabel);
        make.left.equalTo(weakSelf.timeLabel.ECMas_right);
        make.width.ECMas_equalTo(@70);
        make.height.ECMas_equalTo(@30);
    }];
    
    // 返回首页按钮
    self.saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont systemFontOfSize:22];
    self.saveButton.backgroundColor = [UIColor colorWithRed:44.0/255.0 green:116.0/255.0 blue:234.0/255.0 alpha:1.0f];
    [self.saveButton addTarget:self action:@selector(saveButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    [self.saveButton ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view.ECMas_bottom).offset(-100);
        make.centerX.equalTo(weakSelf.view);
        make.left.equalTo(weakSelf.view.ECMas_left).offset(20);
        make.height.ECMas_equalTo(@49);
    }];
}

-(UILabel *)createCommonLabelWithTitle:(NSString *)title
{
    UILabel * label = [[UILabel alloc]init];
    label.text = title;
//    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor colorWithRed:117/255.0 green:116/255.0 blue:124/255.0 alpha:1.0];
    return label;
}

- (void)timeSliderValueDidChanged:(UISlider *)sender
{
    self.timeLabel.text =  [NSString stringWithFormat:@"%.0f",sender.value];
}

- (void)saveButtonDidClicked:(UIButton *)sender
{
    [ECLiveConfig share].timeOut = [self.timeLabel.text intValue];
    [ECLiveConfig share].action = (int)(self.actionControl.selectedSegmentIndex);
    
    switch (self.rotateControl.selectedSegmentIndex) {
        case 0:
        {
            [ECLiveConfig share].liveOrientation = ECLiveOrientationPortrait;
        }
            break;
            
        case 1:
        {
            [ECLiveConfig share].liveOrientation = ECLiveOrientationLeft;
        }
            break;
            
        case 2:
        {
            [ECLiveConfig share].liveOrientation = ECLiveOrientationRight;
        }
            break;
        
        case 3:
        {
            [ECLiveConfig share].liveOrientation = ECLiveOrientationRotation;
        }
            break;
            
        default:
        {
            
        }
            break;
    }
    [ECLiveConfig share].isAudio = self.soundSwitch.on;
    [ECLiveConfig share].deviceIdx = self.backCameraSwitch.on;
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
