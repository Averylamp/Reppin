//
//  BallTrack.m
//  
//
//  Created by Avery Lamp on 8/26/15.
//
//

#import "PersonTracking.hpp"
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/core/core_c.h>
#import <vector>
#import "Global.h"


using std::vector;
using namespace cv;

@implementation PersonTracking
static int trackIndex = 0;
static String TAG = "BallTracking";

int lastX = 0;
int lastY = 0;

int minArea = 900;

int nomovement_counter = 0;

static double repRate = 0;
static String timeLeft = "";

static double first_timestamp = 0;

vector<double*> trackArr;
//ArrayList<double[]> trackArr = new ArrayList<double[]>();
// timestamp, X position, Y position, circle size


vector<double> track_t;
vector<int> track_x;
vector<int> track_y;
vector<double> track_area;

vector<double> MASTER_track_t;
vector<int> MASTER_track_x;
vector<int> MASTER_track_y;
vector<double> MASTER_track_area;

std::vector<int> repData;

static int PEAK_THRESHOLD = 125; // was 35

static int FRAMES_TO_CALC = 15; // how many frames to calculate Exercise rate
//int errorPersist=0;

// THIS IS THE MAIN CODE FOR TRACKING, IT RETURNS THE PROCESSED FRAME AND STORES THE POSITION
-(UIImage*) Track:(cv::Mat) mCameraFrame {
    
    
    Global *global = [Global sharedManager];
    
    // Convert Camera Frame to HSV format
    cv::Mat mCameraFrameHsv;
    cv::cvtColor(mCameraFrame, mCameraFrameHsv, COLOR_RGB2HSV);
    
    //		Imgproc.medianBlur(mCameraFrameHsv, mCameraFrameHsv, 11 ); // too slow
    
    // Generate the Color Mask for the Color Spectrum Range calculated in LogoDetection
    cv::Mat mColorMask = cv::Mat::zeros(mCameraFrame.rows, mCameraFrame.cols, CV_8UC1);
    
    cv::Scalar lowerSpect1 = cv::Scalar(global.LowerSpect[0],global.LowerSpect[1],global.LowerSpect[2],global.LowerSpect[3]);
    cv::Scalar lowerSpect2 = cv::Scalar(global.LowerSpect[4],global.LowerSpect[5],global.LowerSpect[6],global.LowerSpect[7]);
    
    cv::Scalar upperSpect1 = cv::Scalar(global.UpperSpect[0],global.UpperSpect[1],global.UpperSpect[2],global.UpperSpect[3]);
    cv::Scalar upperSpect2 = cv::Scalar(global.UpperSpect[4],global.UpperSpect[5],global.UpperSpect[6],global.UpperSpect[7]);
    
    cv::Scalar fullLowerSpect[2];
    fullLowerSpect[0] = lowerSpect1;
    fullLowerSpect[1] = lowerSpect2;
    
    cv::Scalar fullUpperSpect[2];
    fullUpperSpect[0] = upperSpect1;
    fullUpperSpect[1] = upperSpect2;
    
    
    
    makeColorMask(mCameraFrameHsv, fullUpperSpect,fullLowerSpect, mColorMask);
    
    
    // Dilate and Erode the Mask to Isolate the Ball better    
    dilateErodeMask(mColorMask);
    
    
    // Apply ColorMask to mFilteredFrame
    cv::Mat mFilteredFrame;
    applyMask(mCameraFrame, mColorMask, mFilteredFrame);
  
    
    
    // Find Contours of Blobs
    vector<vector<cv::Point>> contours;
//    List<MatOfPoint> contours = new ArrayList<MatOfPoint>();
//    cv::findContours(mColorMask,contours);
    cv::findContours(mColorMask, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    // Find the Contour with the Largest Area AND is within Ball Radius range
    
    int* response = findBiggestContour(contours, mColorMask);
    int maxContour_id = response[0];
    
    // If there was a Contour detected
    if (maxContour_id != -1) {
        // Calculate the Bounding Area of the Contour
        double area = cv::contourArea(contours[maxContour_id]);
        cv::Rect rc = cv::boundingRect(contours[maxContour_id]);
        cv::rectangle(mCameraFrame, rc, Scalar(0,255,0),2, 8, 0);


        int currentX = rc.x + rc.width / 2;
        int currentY = rc.y + rc.height / 2;
//        int deltaX = abs( global.tracking_last_position[0] - currentX  );
//        int deltaY = abs( global.tracking_last_position[1] - currentY  );
//        int delta = (int) sqrt( deltaX*deltaX + deltaY*deltaY);

        
//        NSLog(@"X - %d, Y - %d, dX - %d, dY - %d, ",currentX, currentY, deltaX, deltaY);
        global.tracking_last_position[0] = currentX;
        global.tracking_last_position[1] = currentY;
        
        
        // Save Ball Tracking Data
        
        
        if (global.STATE == global.PERSON_TRACKING){
            saveTrackingData(rc.x, rc.y, area); // Save the ball position data
         
            calcUpDownRate();
            
        }
    }// endif there was a contour detected
 
    
    // Turn Debug on or Off
//    if (true){
//        mColorMask.copyTo(mCameraFrame);  // useful for seeing the raw filtered data on screen
//    }
    
    
    // Calculate the Remaining Time for Tracking
    int timeInt = (global.TRACKING_TIME_DURATION - TrackingDuration());
    timeLeft = std::to_string(timeInt);
    
    // If the Time is Up
    if (global.currentRepCount == global.repsPerSet) {
#pragma mark - Analytics Function Commented
//        Analytics();	// Calculate the Analytics
        NSLog(@"ENDED");
        NSMutableArray * rawRepData = [[NSMutableArray alloc]init];
        for (int i = 0; i < repData.size(); i++){
            NSNumber* frame = [NSNumber numberWithInt: track_y.at(i)];
            NSNumber* time = [NSNumber numberWithDouble:track_t.at(repData.at(i))];
            NSArray *data = @[frame, time];
            [rawRepData addObject: data];
            [global.allRepData addObject:rawRepData];
        }
        
        clear_TrackingDuration();
        clearTrackingData();
        global.STATE = global.WAIT_FOR_START;
        
    }
    // if Tracking Error Detected
    // change the State to Global.ERROR_TRACKING
    // Return the Processed Camera Frame
    UIImage *returnImage = cvMatToUIImage(mCameraFrame);
//    UIImage *returnImage = cvMatToUIImage(mCameraFrameHsv);
    mCameraFrame.release();
    mFilteredFrame.release();
    mColorMask.release();
    mCameraFrameHsv.release(); // erase this matrix, we're done with it
    return returnImage;
}

static UIImage* cvMatToUIImage(const cv::Mat& m) {
    CV_Assert(m.depth() == CV_8U);
    NSData *data = [NSData dataWithBytes:m.data length:m.elemSize()*m.total()];
    CGColorSpaceRef colorSpace = m.channels() == 1 ?
    CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(m.cols, m.rows, m.elemSize1()*8, m.elemSize()*8,
                                        m.step[0], colorSpace, kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef); CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace); return finalImage;
}

void HighlightIssues(vector<vector<cv::Point>> contours, Mat mFrame) {
    for (int i = 0; i < contours.size(); i++) { // for each contour
        int area = (int) cv::contourArea(contours[i]); // calculate the area
        if (area > minArea) {
            cv::drawContours(mFrame, contours, i, cv::Scalar(0,255,0));
        }
        
    }
}

int* findBiggestContour(vector<vector<cv::Point>> contours,cv::Mat mColorMask) {
    int* response = new int[2];
    
    int maxArea =0;
    int largeSizedContours=0;
    int maxContour_id=-1;
    
    for (int i = 0; i < contours.size(); i++) { // for each contour
        
        int area = (int) contourArea(contours[i]); // calculate the area
        
        
        if (area > minArea) {
            largeSizedContours+=1;

            cv::drawContours(mColorMask, contours, i, cv::Scalar(255,255,255),-1);
            
            if (maxArea < area) { // if this is the largest area so far
                maxArea = area; // update the variables
                maxContour_id = i;
            }
            
        }
        else {
            cv::drawContours(mColorMask, contours, i, cv::Scalar(255,255,255));
        }
       
    } // end for all contours
    
    response[0] = maxContour_id;
    response[1] = largeSizedContours;
    
    return response;
}

 void saveTrackingData(int x, int y, double area) {
    double timestamp = CACurrentMediaTime() * 1000; // timestamp in milliseconds
    double pos[] = { timestamp, (double) x, (double) y, area };
    
//     NSLog(@"Save Timestamp = %f", timestamp);

  //  y = 400 - y; // Invert it because tracking is backwards on Android
    
    // Append to Tracking Data Arrays
    trackArr.push_back(pos);

    track_t.push_back(timestamp);
    track_x.push_back(x);
    track_y.push_back(y);
    track_area.push_back(area);
    MASTER_track_t.push_back(timestamp);
    MASTER_track_x.push_back(x);
    MASTER_track_y.push_back(y);
    MASTER_track_area.push_back(area);
     
    trackIndex++; // increment the index for the tracking data
    
}
//
//// Global Variables for Dribble Stuff



 void calcUpDownRate() {
    if (trackIndex % FRAMES_TO_CALC == 0) {
        std::vector<int> pks = peakdetect(track_y,PEAK_THRESHOLD);
        NSLog(@"Finding peaks");
        if (pks.size() > 0) { // if there are 3 peaks detected
            double* temp = new double[pks.size()];
            double sum = 0;
            double avg = 0;
            repData = pks;

            if (pks.size() >= 4){
                for (int i = pks.size() - 3; i < pks.size(); i++) {
                
                temp[i] = (track_t.at(pks.at(i)) - track_t.at(pks.at(i - 1))) / 1000; // to seconds
                sum = sum + temp[i];
                }
                avg = sum / 3;
            }
            

            repRate = 1.0 / avg;
            
            NSLog(@"# Peaks = %d", (pks.size()) );
            NSLog(@"Avg Delta Peak = %f", avg);
            NSLog(@"DPS = %f", repRate);
            NSLog(@"Length Before = %ld", track_x.size() );

            Global *global = [Global sharedManager];
            global.currentRepCount = pks.size();
            global.currentRepPerSec = repRate;
            
            
        }
    }
}


void clearTrackingData() {
    trackArr.clear();
    track_t.clear();
    track_x.clear();
    track_y.clear();
    track_area.clear();
    trackIndex = 0;
}



void makeColorMask(cv::Mat mCameraFrameHsv,  cv::Scalar* UpperSpect, cv::Scalar* LowerSpect, cv::Mat mColorMask) {
    // Create a mask for the colors of interest, into mColorMask
    cv::Mat temp1;
    cv::Mat temp2;
    
    cv::inRange(mCameraFrameHsv,UpperSpect[0], UpperSpect[1], temp1);
    cv::inRange(mCameraFrameHsv, LowerSpect[0], LowerSpect[1], temp2);
    cv::bitwise_or(temp1, temp2, mColorMask);
    
    temp1.release();
    temp2.release();
}

void dilateErodeMask(cv::Mat mColorMask) {
    // Filter with Dilation/Erosion
    cv::Size erosionSize = cv::Size(15,15);
    cv::dilate(mColorMask, mColorMask, cv::getStructuringElement(MORPH_RECT, erosionSize));
    
     erosionSize = cv::Size(15,15);
    cv::erode(mColorMask, mColorMask, cv::getStructuringElement(MORPH_RECT, erosionSize));
}

void applyMask(cv::Mat mCameraFrame, cv::Mat mColorMask, cv::Mat mFilteredFrame) {
    // Filter the Camera frame to black
     mFilteredFrame.setTo(cv::Scalar(0, 0, 0) ); // clear to black originally

    mCameraFrame.copyTo(mFilteredFrame, mColorMask); // show filtered image
}


 static std::vector<int> peakdetect(std::vector<int> v, int delta) {
    long mn = 9999999;
    long mx = -9999999;
    
    int mnpos = 0;// null;
    int mxpos = 0;// null;
    
    std::vector<int> peaks;
    Boolean lookformax = true;
    
    for (int i = 0; i < v.size(); i = i + 1) {
        int this_v = v[i];
        if (this_v > mx) {
            mx = this_v;
            mxpos = i;
        }
        if (this_v < mn) {
            mn = this_v;
            mnpos = i;
        }
        if (lookformax) {
            if (this_v < mx - delta) {
                peaks.push_back(mxpos);
                mn = this_v;
                mnpos = i;
                lookformax = false;
            }
        } else {
            if (this_v > mn + delta) {
                mx = this_v;
                mxpos = i;
                lookformax = true;
            } // endif
        }

    }
    return peaks;
}

 void clear_TrackingDuration() {
    first_timestamp = -1;
}

 int TrackingDuration() {
     double timestamp = CACurrentMediaTime();
     if (first_timestamp > 0) {
        return (int) ((timestamp - first_timestamp));
    } else {
        first_timestamp = timestamp;
        return 0;
    }
}
-(void)clearTrackingDuration{
    clear_TrackingDuration();
}

@end
