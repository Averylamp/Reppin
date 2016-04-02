//
//  Global.h
//  Dribbler
//
//  Created by Avery Lamp on 8/27/15.
//  Copyright © 2015 Vidyadhar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject

@property int LOGO_DETECTION;
@property int BALL_TRACKING;
@property int ANALYTICS;
@property int DRIBBLE_SPEED;
@property int TIME_LEFT;
@property int ERROR_LIGHTING;
@property int ERROR_BLOBS;

@property int STATE;

@property int* LowerSpect;
@property int* UpperSpect;
//public static Scalar[] LowerSpect = new Scalar[2];
//public static Scalar[] UpperSpect = new Scalar[2];


@property int peakH;
@property int peakS;
@property int peakV;
@property long rejectedPixels;

// Global Settings
@property int TRACKING_TIME_DURATION;
@property double LOW_LIGHT_FPS_THRESHOLD ;

@property int CONFIDENCE_THRESHOLD; // percentage confidence for a logo

@property int TRAINING_FREESTYLE;

@property int CALIBRATE_FRAME_WIDTH;
@property int CALIBRATE_FRAME_HEIGHT;

@property int TRACKING_FRAME_WIDTH;
@property int TRACKING_FRAME_HEIGHT;


@property int HUNDRED_dribbleRate;
@property int HUNDRED_maxDribbleRate;
@property int HUNDRED_heightConsistency;
@property int HUNDRED_numCrossovers;
@property int HUNDRED_crossoverWidth;
@property int HUNDRED_locationAccuracy;

@property int* S_limit;
@property int* V_limit;
//public static int[] S_limit = new int[2];
//public static int[] V_limit = new int[2];


@property  NSString* AccessToken;

@property long last_frame;

@property int spread;

//public static final String serverURL = "http://192.168.1.5:8000";
@property NSString* serverURL;

@property NSString* SessionKey;



@property int INVITED_STATUS;
@property int ACTIVE_STATUS;
@property int COMPLETED_STATUS;


@property int TRAINING_SESSION;
@property int CHALLENGE_SESSION;

@property int SPEED_DRIBBLING;
@property int MAX_CROSSOVERS;
@property int FATIGUE_CHALLENGE;

@property int FREESTYLE;
@property int MAX_DRIBBLE_SPEED;
@property int FAST_AND_HIGH;
@property int FATIGUE_TEST;
@property int CROSSOVER;
@property int CROSSOVER_ADVANCED;


@property int* tracking_last_position;

@property BOOL isDebug;

@property int S_mean;


@property BOOL DEBUG_TRACKING; // true to show the debug output, black and white

+ (id)sharedManager;


@end
