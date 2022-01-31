//
//  HighFidelityCGImages.m
//  iOSAtomSegNet
//
//  Created by sebi d on 1/30/22.
//

#import "HighFidelityCGImages.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreGraphics/CGColorSpace.h>

@implementation HighFidelityCGImages
//-(void) ConstructImgGreyScale
//{
//CGBitmapInfo     bitmapInfo;
//int bytesPerRow;
//
//switch ([self BITPIX])   // BITPIX : Number bits/pixel. Information extracted from the FITS header
//{
//    case 8:
//        bytesPerRow=sizeof(int8_t);
//        bitmapInfo = kCGImageAlphaNone ;
//        break;
//    case 16:
//        bytesPerRow=sizeof(int16_t);
//        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrder16Big;
//        break;
//    case 32:
//        bytesPerRow=sizeof(int32_t);
//        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrder32Big;
//        break;
//    case 64:
//        bytesPerRow=sizeof(int64_t);
//        bitmapInfo = kCGImageAlphaNone;
//        break;
//    case -32:
//        bytesPerRow=sizeof(Float32);
//        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrder32Big  | kCGBitmapFloatComponents;
//    case -64:
//        bytesPerRow=sizeof(Float64);
//        bitmapInfo = kCGImageAlphaNone  | kCGBitmapFloatComponents;
//        break;
//    default:
//        NSLog(@"Unknown pixel bit size");
//        return;
//}
//[self setBitsPerSample:abs([self BITPIX])];
//
//[self setColorSpaceName:NSCalibratedWhiteColorSpace];
//
//[self setPixelsWide:[self NAXESofAxis:0]]; // <- Size of the X axis. Extracted from FITS header
//[self setPixelsHigh:[self NAXESofAxis:1]]; // <- Size of the Y axis. Extracted from FITS header
//
//[self setSize:  NSMakeSize( 2*[self pixelsWide], 2*[self pixelsHigh])];
//
//[self setAlpha: NO];
//[self setOpaque:NO];
//
//CGDataProviderRef provider=CGDataProviderCreateWithCFData ((CFDataRef) Img);
//
//CGFloat Scale[2]={0,28};
//image = CGImageCreate ([self pixelsWide],
//                       [self pixelsHigh],
//                       [self bitsPerSample],
//                       [self bitsPerSample],
//                       [self pixelsWide]*bytesPerRow,
//                       [[NSColorSpace deviceGrayColorSpace] CGColorSpace],
//                       bitmapInfo,
//                       provider,
//                       NULL,
//                       NO,
//                       kCGRenderingIntentDefault
//                       );
//
//CGDataProviderRelease(provider);
//return;
//}

+ (void *) getF32CGImage:(void *)f32DataPointer
              pixelsWide:(int)pixelsWide
              pixelsHigh:(int)pixelsHigh
{
    CGBitmapInfo bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrder32Big  | kCGBitmapFloatComponents;

    int bytesPerRow=sizeof(Float32);
    CFIndex length = 4 * pixelsHigh * pixelsWide;
    
    CFDataRef dataRef = CFDataCreate(NULL, ((UInt8 *)f32DataPointer), length);
    CGDataProviderRef provider=CGDataProviderCreateWithCFData ((CFDataRef) dataRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGImage* image = CGImageCreate (pixelsWide,
                           pixelsHigh,
                           32,
                           32,
                           pixelsWide*4,
                           colorSpace,
                           bitmapInfo,
                           provider,
                           NULL,
                           NO,
                           kCGRenderingIntentDefault
                           );
    CGDataProviderRelease(provider);
    return image;
}
@end
