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
@property int PERSON_TRACKING;
@property int ANALYTICS;
@property int DRIBBLE_SPEED;
@property int TIME_LEFT;
@property int ERROR_LIGHTING;
@property int ERROR_BLOBS;
@property int DETECT_PERSON;
@property int WAIT_FOR_START;

@property int currentRepCount;
@property int currentRepPerSec;
@property int STATE;

@property int repsPerSet;

@property int* LowerSpect;
@property int* UpperSpect;

@property NSMutableArray * allRepData;
//public static Scalar[] LowerSpect = new Scalar[2];
//public static Scalar[] UpperSpect = new Scalar[2];

@property int minH;
@property int maxH;

@property int peakH;
@property int peakS;
@property int peakV;
@property long rejectedPixels;

// Global Settings
@property int TRACKING_TIME_DURATION;
@property double LOW_LIGHT_FPS_THRESHOLD ;

@property int CONFIDENCE_THRESHOLD; // percentage confidence for a logo

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



@property int* tracking_last_position;

@property BOOL isDebug;

@property int S_mean;


@property BOOL DEBUG_TRACKING; // true to show the debug output, black and white

+ (id)sharedManager;


@end
