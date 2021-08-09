//
//  ECImageUtil.m
//  EyeCoolFace
//
//  Created by cocoa on 2018/9/27.
//  Copyright © 2018年 dev.keke@gmail.com. All rights reserved.
//

#import "ECImageUtil.h"
//#import "GPUImage.h"

@implementation ECImageUtil

+ (UIImage *)argbImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    return image;
}

+ (NSData *)rgbDataFromArgbImage:(UIImage *)image{
    NSData *imgDT = UIImageJPEGRepresentation(image, 1.0f);
    UIImage *jpgIMG = [UIImage imageWithData:imgDT];
    CGImageRef cgimage = jpgIMG.CGImage;
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData* srcData = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    Byte *srcBTS = (Byte *)srcData.bytes;
    int srcSize = (int )srcData.length;
    int rgbSize = srcSize/4*3;
    int rgbIndex = 0;
    Byte *rgb = (Byte *)malloc(rgbSize);
    bzero(rgb, rgbSize);
    //JPG，为RGB无Alpha通道
    for (int i = 0; i < srcSize; i+=4) {
        rgb[rgbIndex] = srcBTS[i];
        rgb[rgbIndex+1] = srcBTS[i+1];
        rgb[rgbIndex+2] = srcBTS[i+2];
        rgbIndex += 3;
    }
    NSData *rgbDT = [NSData dataWithBytes:rgb length:rgbSize];
    free(rgb);
    rgb = NULL;
    return rgbDT;
}

 + (UIImage *)image:(UIImage *)image
           rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
      
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = -M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
      
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
      
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
      
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
      
    return newPic;
}

//+ (UIImage *)getRotationImage:(UIImage *)image
//                     rotation:(UIImageOrientation)orientation {
//
//    NSLog(@"GPU:传入的image-size:%f * %f",image.size.width,image.size.height);
//    GPUImageTransformFilter * filter = [[GPUImageTransformFilter alloc]init];
//    switch (orientation) {
//        case UIImageOrientationLeft:
//        {
//            filter.affineTransform = CGAffineTransformMakeRotation(-M_PI_2);
//            [filter forceProcessingAtSize:CGSizeMake(image.size.height, image.size.width)];
//        }
//            break;
//            
//        case UIImageOrientationRight:
//        {
//            filter.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
//            [filter forceProcessingAtSize:CGSizeMake(image.size.height, image.size.width)];
//        }
//            break;
//            
//            
//        case UIImageOrientationDown:
//        {
//            filter.affineTransform = CGAffineTransformMakeRotation(M_PI);
//            [filter forceProcessingAtSize:image.size];
//        }
//            break;
//            
//        default:
//        {
//            filter.affineTransform = CGAffineTransformMakeRotation(0.0);
//            [filter forceProcessingAtSize:image.size];
//        }
//            break;
//    }
//    
//    
//    
//    filter.ignoreAspectRatio = NO;
//    [filter useNextFrameForImageCapture];
//    
//    GPUImagePicture *imageSource = [[GPUImagePicture alloc]initWithImage:image];
//    [imageSource addTarget:filter];
//    [imageSource processImage];
//    
//    UIImage * newImage = [filter imageFromCurrentFramebuffer];
//    NSLog(@"GPU:image-size:%f * %f",newImage.size.width,newImage.size.height);
//    return newImage;
//}

@end
