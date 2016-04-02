//
//  Global.m
//  Dribbler
//
//  Created by Avery Lamp on 8/27/15.
//  Copyright © 2015 Vidyadhar. All rights reserved.
//

#import "Global.h"
#import <opencv2/core/core_c.h>

@implementation Global

//Singleton Methods

+ (id)sharedManager {
    static Global *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        // All final variables
        self.LOGO_DETECTION=1;
        self.BALL_TRACKING=2;
        self.ANALYTICS=3;
        self.DRIBBLE_SPEED=4;
        self.TIME_LEFT = 5;
        self.ERROR_LIGHTING=6;
        self.ERROR_BLOBS=7;
        
        self.CONFIDENCE_THRESHOLD = 40; // percentage confidence for a logo
        
        self.TRAINING_FREESTYLE=1;
        
        self.CALIBRATE_FRAME_WIDTH = 1200;
        self.CALIBRATE_FRAME_HEIGHT = 800;
        
        self.TRACKING_FRAME_WIDTH = 480;
        self.TRACKING_FRAME_HEIGHT = 320;
        
        
        self.HUNDRED_dribbleRate = 10;
        self.HUNDRED_maxDribbleRate = 10;
        self.HUNDRED_heightConsistency = 100;
        self.HUNDRED_numCrossovers = 30;
        self.HUNDRED_crossoverWidth = 3;
        self.HUNDRED_locationAccuracy = 100;
        
        self.INVITED_STATUS=1;
        self.ACTIVE_STATUS=2;
        self.COMPLETED_STATUS=3;
        
        
        self.TRAINING_SESSION=1;
        self.CHALLENGE_SESSION=2;
        
        self.SPEED_DRIBBLING=1;
        self.MAX_CROSSOVERS=2;
        self.FATIGUE_CHALLENGE=3;
        
        self.FREESTYLE=1;
        self.MAX_DRIBBLE_SPEED=2;
        self.FAST_AND_HIGH=3;
        self.FATIGUE_TEST=4;
        self.CROSSOVER=5;
        self.CROSSOVER_ADVANCED=6;
        
        //Editable variables
        self.peakH = 4;
        self.peakS = 132;
        self.peakV = 0;
        self.spread = 0;
        self.S_mean = 0;
        self.LOW_LIGHT_FPS_THRESHOLD = 4;
        self.TRACKING_TIME_DURATION = 30;
        self.rejectedPixels = 0;
        self.last_frame = 0;
        self.serverURL = @"http://52.2.187.118"; // NOTE! YOU NEED TO CHANGE THIS IN SWIFT TOO
        self.SessionKey = @"e1fj7ph2glquw6lgnrvllfk4j0x3nml6";
        self.isDebug = NO;
        self.DEBUG_TRACKING = NO;
        
        //Arrays
        self.S_limit = new int[2];
        self.V_limit = new int[2];
        self.LowerSpect = new int[8];
        self.UpperSpect = new int[8];
        self.tracking_last_position = new int[2];
         
        
    }
    return self;
}

@end
