//
//  ResultViewController.h
//  ECFaceApp
//
//  Created by eyecool on 2020/7/3.
//  Copyright © 2020 eyecool. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResultViewController : UIViewController

// 上个控制器传过来的是否识别成功的标识
@property (nonatomic , assign) BOOL isSuccess;
// 上个控制器传过来的image
@property (nonatomic,strong)UIImage * img;
// 错误码
@property (nonatomic,strong)NSString * errMsg;

@end

NS_ASSUME_NONNULL_END
