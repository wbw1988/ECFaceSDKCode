//
//  ECCameraManager.h
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/26.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
    代理，回调视频流,原生格式的数据
 */
@protocol ECCameraBufferDelegate <NSObject>
- (void)cameraDidOutputBuffer:(CMSampleBufferRef )sampleBuffer;

@end

/**
    摄像头管理器
 **/
@interface ECCameraManager : NSObject
@property (nonatomic,assign)id delegate;

@property(nonatomic , strong)AVCaptureConnection *theVideoConnection;

//初始化摄像头方向，位置，分辨率
- (instancetype)initWithVideoOrientation:(AVCaptureVideoOrientation )vdOri
                          cameraPosition:(AVCaptureDevicePosition )vdPosition
                           sessionPreset:(AVCaptureSessionPreset )vdPreset;

//打开摄像头
- (BOOL)openCameraWithVideoConnection:(AVCaptureVideoOrientation)videoOrientation;

//关闭摄像头
- (BOOL)closeCamera;

//开始出视频流
- (BOOL)startBuffer;

//停止出视频流
- (BOOL)stopBuffer;

//视频预览
- (void)showPreviewOnLayer:(CALayer *)layer frame:(CGRect )frame;

//修改视频预览方向大小
- (void)changePreviewOritation:(AVCaptureVideoOrientation )vdOri
                     showFrame:(CGRect )frame;

@end

NS_ASSUME_NONNULL_END
