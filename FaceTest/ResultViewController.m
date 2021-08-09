//
//  ResultViewController.m
//  ECFaceApp
//
//  Created by eyecool on 2020/7/3.
//  Copyright © 2020 eyecool. All rights reserved.
//

#import "ResultViewController.h"
#import "ECMasonry.h"

@interface ResultViewController ()

// 识别结果图片
@property (nonatomic , strong) UIImageView * resultImageView;
// 消息label
@property (nonatomic , strong) UILabel * msgLabel;

@property (nonatomic , strong) UIButton * backButton;

@end

@implementation ResultViewController

// 不支持屏幕自动旋转
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    // 支持垂直 左 右
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 布局所有子视图
    [self layoutAllSubviews];
}

- (void)layoutAllSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    //
    __weak typeof(self) weakSelf = self;
    
    self.resultImageView = [[UIImageView alloc]init];
    self.resultImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.resultImageView];
    if (self.isSuccess == YES)
    {
        self.resultImageView.image = self.img;
        [self.resultImageView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.top.equalTo(weakSelf.view).offset(100);
            make.centerX.equalTo(weakSelf.view);
            make.width.ECMas_equalTo(@280);
            make.height.ECMas_equalTo(@280);
        }];
    }
    else
    {
        self.resultImageView.image = [UIImage imageNamed:@"errorIMG"];
        [self.resultImageView ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.view.ECMas_centerY);
            make.centerX.equalTo(weakSelf.view);
            make.width.ECMas_equalTo(@200);
            make.height.ECMas_equalTo(@200);
        }];
    }
    
    // msgLabel
    self.msgLabel = [[UILabel alloc]init];
    self.msgLabel.font = [UIFont systemFontOfSize:22];
    self.msgLabel.text = self.errMsg;
    CGFloat msgWidth = [self getWidthWithTitle:self.errMsg font:self.msgLabel.font];
    [self.view addSubview:self.msgLabel];
    [self.msgLabel ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.resultImageView);
        make.top.equalTo(weakSelf.resultImageView.ECMas_bottom).offset(50);
        make.width.ECMas_equalTo(msgWidth);
        make.height.ECMas_equalTo(@30);
    }];
    if (self.isSuccess == YES) {
        self.msgLabel.textColor = [UIColor colorWithRed:42/255.0 green:216/255.0 blue:160/255.0 alpha:1];
    }
    else
    {
        self.msgLabel.textColor = [UIColor redColor];
    }
    
    
    // 返回首页按钮
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setTitle:@"返回首页" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:22];
    self.backButton.backgroundColor = [UIColor colorWithRed:44.0/255.0 green:116.0/255.0 blue:234.0/255.0 alpha:1.0f];
    [self.backButton addTarget:self action:@selector(backButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    [self.backButton ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view.ECMas_bottom).offset(-100);
        make.centerX.equalTo(weakSelf.view);
        make.left.equalTo(weakSelf.view.ECMas_left).offset(20);
        make.height.ECMas_equalTo(@49);
    }];
}

// 回到首页
- (void)backButtonDidClicked:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width;
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
