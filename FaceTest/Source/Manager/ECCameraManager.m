//
//  ECCameraManager.m
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/26.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import "ECCameraManager.h"
#import <AVFoundation/AVFoundation.h>

@interface ECCameraManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    //摄像头配置Session
    AVCaptureSession *videoSession;
    //输入设备
    AVCaptureDeviceInput *inputDevice;
    
    /*
     AVCaptureMovieFileOutput (输出一个 视频文件)
    AVCaptureVideoDataOutput  (可以采集数据从指定的视频中)
    AVCaptureAudioDataOutput  (采集音频)
    AVCaptureStillImageOutput (采集静态图片)
     */
    
    //输出设备
    AVCaptureVideoDataOutput *outputDevice;
    //预览layer
    AVCaptureVideoPreviewLayer *videoPreLayer;
    //
    dispatch_queue_t videoQueue;
    
    //摄像头(前置、后置)
    AVCaptureDevicePosition theVideoPosition;
    //设置采集的质量
    AVCaptureSessionPreset theSessionPreset;
    
    
    BOOL bCameraOpen;
    BOOL bBufferStart;

}


@property (nonatomic,assign)AVCaptureVideoOrientation theVideoOri;

@end

@implementation ECCameraManager

- (instancetype)initWithVideoOrientation:(AVCaptureVideoOrientation )vdOri
                          cameraPosition:(AVCaptureDevicePosition )vdPosition
                           sessionPreset:(AVCaptureSessionPreset )vdPreset{
    self = [super init];
    
    if (self) {
        
        self.theVideoOri = vdOri;
        theVideoPosition = vdPosition;
        theSessionPreset = vdPreset;
        bCameraOpen = NO;
        bBufferStart = NO;
        
    }
    
    return self;
}



- (BOOL)openCameraWithVideoConnection:(AVCaptureVideoOrientation)videoOrientation
{
    return [self setupCameraWithVideoConnection:videoOrientation];
}

- (BOOL)closeCamera{
    return [self removeCamera];
}

- (BOOL)startBuffer{
    if (bCameraOpen) {
        if (bBufferStart) {
            return YES;
        }
        [videoSession startRunning];
        bBufferStart = YES;
        return YES;
    }
    return NO;
}

- (BOOL)stopBuffer{
    if (bCameraOpen) {
        if (bBufferStart) {
            [videoSession stopRunning];
            bBufferStart = NO;
            return YES;
        }
    }
    return NO;
}

- (void)showPreviewOnLayer:(CALayer *)layer frame:(CGRect )frame{
    
    if (!videoSession) {
        return;
    }
    
    if (videoSession.isRunning) {
        return;
    }
    videoPreLayer = [AVCaptureVideoPreviewLayer layerWithSession:videoSession];
    videoPreLayer.frame = frame;
    videoPreLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [layer addSublayer:videoPreLayer];
}

- (void)changePreviewOritation:(AVCaptureVideoOrientation )vdOri
                     showFrame:(CGRect )frame{
    if (!bCameraOpen) {
        return;
    }
    
    videoPreLayer.frame = frame;
    videoPreLayer.connection.videoOrientation = vdOri;

    
}

#pragma mark private

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(cameraDidOutputBuffer:)]) {
        [self.delegate cameraDidOutputBuffer:sampleBuffer];
    }
}

- (BOOL)setupCameraWithVideoConnection:(AVCaptureVideoOrientation)videoOrientation{
    if (bCameraOpen) {
        return YES;
    }
    videoSession = [[AVCaptureSession alloc] init];
    if (![videoSession canSetSessionPreset:theSessionPreset]) {
        NSLog(@"ECCameraManager: SetSessionPreset Error");
        return NO;
    }
    videoSession.sessionPreset = theSessionPreset;
    
    inputDevice = [self inputDeviceWithPosition:theVideoPosition];
    if (!inputDevice) {
        NSLog(@"ECCameraManager: get Camera Error");
        return NO;
    }
    
    if (![videoSession canAddInput:inputDevice]) {
        NSLog(@"ECCameraManager: add input Error");
        return NO;
    }
    [videoSession addInput:inputDevice];
    
    
    outputDevice = [[AVCaptureVideoDataOutput alloc] init];
    if (![videoSession canAddOutput:outputDevice]) {
        NSLog(@"ECCameraManager: add output Error");
        return NO;
    }
    [videoSession addOutput:outputDevice];
    
    videoQueue = dispatch_queue_create("cn.eyecool.FaceSingleQ",NULL); // 串行queue
    [outputDevice setSampleBufferDelegate:self queue:videoQueue];

    outputDevice.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    self.theVideoConnection = [outputDevice connectionWithMediaType:AVMediaTypeVideo];
    // 设置采集数据的方向、镜像
    self.theVideoConnection.videoOrientation = videoOrientation;
    //theVideoConnection.videoMirrored = YES;
    bCameraOpen = YES;
    return YES;
}


- (BOOL)removeCamera{
    if (bCameraOpen==NO) {
        return YES;
    }
    [videoSession beginConfiguration];
    [videoSession removeOutput:outputDevice];
    [videoSession removeInput:inputDevice];
    [videoSession commitConfiguration];
    videoSession = nil;
    outputDevice = nil;
    inputDevice = nil;
    videoQueue = nil;
    bCameraOpen = NO;
    if (videoPreLayer) {
        [videoPreLayer removeFromSuperlayer];
        videoPreLayer = nil;
    }
    return YES;
}


//获取摄像头
- (AVCaptureDeviceInput *)inputDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSError *error = nil;
    //输入设备
    NSArray *allDevices = [AVCaptureDevice
                           devicesWithMediaType:AVMediaTypeVideo];
    if (allDevices.count <1) {
        NSLog(@"ECCameraManager: 设置错误：没有发现任何可用摄像头");
        return nil;
    }
    AVCaptureDevice *device = nil;
    for (AVCaptureDevice *theDevice in allDevices) {
        if (theDevice.position==position) {
            device = theDevice;
        }
    }
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                error:&error];
    if (!input) {
        NSLog(@"ECCameraManager: 摄像头打开错误 %@",error);
        return nil;
    }
    return input;
}

- (void)dealloc
{
    videoSession = nil;
    outputDevice = nil;
    inputDevice = nil;
    videoPreLayer = nil;
    videoQueue = nil;
    //NSLog(@"CameraManager dealloc");
}

@end
