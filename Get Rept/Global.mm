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
        self.PERSON_TRACKING=2;
        self.ANALYTICS=3;
        self.DRIBBLE_SPEED=4;
        self.TIME_LEFT = 5;
        self.ERROR_LIGHTING=6;
        self.ERROR_BLOBS=7;
        self.DETECT_PERSON=8;
        self.WAIT_FOR_START = 9;
        
        self.allRepData = [[NSMutableArray alloc]init];
        
        self.currentRepCount = 0;
        self.currentRepPerSec = 0;
        self.repsPerSet = 10;
        
        self.minH = 0;
        self.maxH = 0;
        
        self.CONFIDENCE_THRESHOLD = 40; // percentage confidence for a logo

        
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
