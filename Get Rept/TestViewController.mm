//
//  TestViewController.m
//  Dribbler
//
//  Created by Avery Lamp on 8/6/15.
//  Copyright © 2015 Vidyadhar. All rights reserved.
//

#import "TestViewController.hpp"
#import <objc/message.h>
#import "Global.h"

@interface TestViewController ()

//@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property BOOL firstImage;
@property UIImageView *imageView;
@property ImageProcessor *imageProcessor;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    Global * global = [Global sharedManager];
    global.STATE = global.LOGO_DETECTION;
    NSLog(@"State - %d", global.LOGO_DETECTION);
    self.imageProcessor = [[ImageProcessor alloc]init];
    
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft
//                                animated:YES];
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    self.imageView = [[UIImageView alloc]init];
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
//    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
//    [self.imageView setHidden:YES];
    self.videoSource = [[VideoSource alloc] init];
    self.videoSource.delegate = self;
    [self.videoSource startWithDevicePosition:AVCaptureDevicePositionFront];
    lowHD = 40, lowH = 40;
    lowSD = 100, lowS = 100;
    lowVD = 100, lowV = 100;
    highHD = 80, highH = 80;
    highSD = 255, highS = 255;
    highVD = 255, highV = 255;
    self.firstImage = true;
     // Do any additional setup after loading the view.
    }

-(void)viewDidAppear:(BOOL)animated{
    Global * global = [Global sharedManager];
    global.STATE = global.DETECT_PERSON;
    NSLog(@"State - %d", global.LOGO_DETECTION);
    [self.videoSource.captureSession startRunning];
    [self.imageProcessor clearTrackingDurations];
}




//-(BOOL)shouldAutorotate{
//    return NO;
//}


- (void)frameReady:(VideoFrame)frame{
//    NSLog(@"Frame");
    
    if (self.firstImage){
        self.firstImage = NO;
        return;
    }
    dispatch_sync( dispatch_get_main_queue(), ^{
        // Construct CGContextRef from VideoFrame
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(frame.data,
                                                          frame.width,
                                                        frame.height,
                                                        8,
                                                        frame.stride,
                                                        colorSpace,
                                                        kCGBitmapByteOrder32Little |
                                                        kCGImageAlphaPremultipliedFirst);
        
        // Construct CGImageRef from CGContextRef
        CGImageRef newImage = CGBitmapContextCreateImage(newContext);
        
        // Construct UIImage from CGImageRef
        UIImage * image = [UIImage imageWithCGImage:newImage];

        image = [self.imageProcessor processImage:image debug:NO values:@[[NSNumber numberWithDouble:lowH],[NSNumber numberWithDouble:lowS],[NSNumber numberWithDouble:lowV],[NSNumber numberWithDouble:highH], [NSNumber numberWithDouble:highS], [NSNumber numberWithDouble:highV]]] ;
        
        [self.imageView setImage:image];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        NSLog(@"Frame - %f, %f", image.size.width, image.size.height);
        
        Global *global = [Global sharedManager];
        if (global.STATE == 3){ // if Global State == Analytics
            [self.videoSource.captureSession stopRunning];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                        @"Main" bundle:[NSBundle mainBundle]];

          
            // AVERY: STOP THE THREAD WITH ALL THE CAMERA FRAMES
            // AVERY: OPEN A NEW VIEW CONTROLLER
        }
        
        CGImageRelease(newImage);
        CGContextRelease(newContext);
//                        CGColorSpaceRelease(colorSpace);
    });
}


- (void)didReceiveMemoryWarning {
     // Dispose of any resources that can be recreated.
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Rotated to size %f, %f",size.width, size.height);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
