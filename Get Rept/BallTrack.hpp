//
//  BallTrack.h
//  
//
//  Created by Avery Lamp on 8/26/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import "ImageProcessor.hpp"

@interface BallTrack : NSObject
@property ImageProcessor* imageProcessor;

-(UIImage*) Track:(cv::Mat) mCameraFrame;
-(void)clearTrackingDuration;
@end
