//
//  TestViewController.h
//  Dribbler
//
//  Created by Avery Lamp on 8/6/15.
//  Copyright © 2015 Vidyadhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSource.h"
#import "ImageProcessor.hpp"

@interface TestViewController : UIViewController <VideoSourceDelegate>
{
    double lowHD, lowSD, lowVD, highHD, highSD,highVD;
    double lowH, lowS, lowV, highH, highS,highV;
    CGPoint touchPoint;
    
}

@property VideoSource* videoSource;




@end
