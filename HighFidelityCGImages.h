//
//  HighFidelityCGImages.h
//  iOSAtomSegNet
//
//  Created by sebi d on 1/30/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HighFidelityCGImages : NSObject
+ (void *) getF32CGImage:(void *)f32DataPointer
              pixelsWide:(int)pixelsWide
              pixelsHigh:(int)pixelsHigh;
@end

NS_ASSUME_NONNULL_END
