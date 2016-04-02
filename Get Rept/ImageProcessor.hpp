//  Image Processor

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@class UIImage;

@interface ImageProcessor : NSObject{
    
}

@property cv::Mat image;
@property cv::Mat image_copy;

- (UIImage*)processImage:(UIImage*)image debug:(BOOL) deb values:(NSArray*) vals;
+ (NSArray*) getColorAtPoint: (CGPoint)point fromImage:(UIImage*)img;
-(void)clearTrackingDurations;
@end
