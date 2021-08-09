//
//  ECCoverView.h
//  EyeCoolFace
//
//  Created by cocoa on 2019/1/13.
//  Copyright © 2019年 dev.keke@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECDALabeledCircularProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ECCoverViewDelegate<NSObject>

@required
//点击关闭的按钮代理
- (void)didClickECCoverViewCloseBtn;

@end

@interface ECCoverView : UIView
@property (nonatomic,strong)UIView *liveView;   //摄像头预览区
@property (nonatomic,strong) UIImageView *backImgView;   //背景图
@property (nonatomic,assign)CGRect liveFrame;   //摄像头预览区域
@property (nonatomic,strong)UILabel *stateLB;   //提示文字

@property (nonatomic,strong)UILabel *tipsLB;   //到期lic提示文字

@property (nonatomic,strong)ECDALabeledCircularProgressView *progressView;   //到计时
@property (nonatomic , strong) UIImageView *animationImgView; //做动作的视图
@property (nonatomic , strong) UIButton *closeBtn; //做动作的视图

@property (nonatomic , strong) UIView * detailView; // 展示详细信息的view,宽高240,上面布局animationImgView,stateLB和测试license的label
@property (nonatomic,assign)id delegate;


//当人脸进入时切换UI边框
- (void)setFaceInUI;

//当人脸离开时切换UI边框
- (void)setFaceOutUI;

//切换播放中间部分人脸动画
- (void)playFaceAnimation:(int )type;

//停止播放中间部分人脸动画；
- (void)stopFaceAnimation;

@end

NS_ASSUME_NONNULL_END
