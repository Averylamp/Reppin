//Image Processor


#import "ImageProcessor.hpp"
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/core/core_c.h>
#import <vector>
#import "PersonTracking.hpp"
#import "Global.h"

using std::vector;
using namespace cv;
@interface ImageProcessor()

@property NSMutableArray *brandStrings;
@property PersonTracking* personTracker;
@property Global* global;
@end


@implementation ImageProcessor


//Objects that arent global

static int S_limit[2];
static int* V_limit;



//public static final String serverURL = "http://192.168.1.5:8000";

static int INVITED_STATUS=1;
static int ACTIVE_STATUS=2;
static int COMPLETED_STATUS=3;

static int TRAINING_SESSION=1;
static int CHALLENGE_SESSION=2;

static int SPEED_DRIBBLING=1;
static int MAX_CROSSOVERS=2;
static int FATIGUE_CHALLENGE=3;

static int FREESTYLE=1;
static int MAX_DRIBBLE_SPEED=2;
static int FAST_AND_HIGH=3;
static int FATIGUE_TEST=4;
static int CROSSOVER=5;
static int CROSSOVER_ADVANCED=6;

static int tracking_last_position[2];

static Boolean isDebug= false;

static int S_mean=0;

static Boolean DEBUG_TRACKING=true; // true to show the debug output, black and white


//Context appContext; //vd: what's this?

double LOGO_FRAME_THRESHOLD = 1;

cv::Mat logoImg_ua[4];
cv::Mat logoImg_nike[4];
cv::Mat logoImg_spalding[1];
cv::Mat logoImg_wilson[4];

std::vector<cv::Mat *> logoImages;

Scalar BLUE_COLOR( 0, 176, 217 );

static double first_timestamp = 0;

String brandString[] = {"UnderArmour", "Nike", "Wilson", "Spalding"};


//int logoBrands[3];
//cv::Mat logoBrands = {logoImg_ua, logoImg_wilson, logoImg_nike, logoImg_spalding};

-(id)init {
    if (self = [super init]){
        // Initial values
        self.personTracker = [[PersonTracking alloc]init];
        self.personTracker.imageProcessor = self;
        
        self.global = [Global sharedManager];
        
        
        //        Under Armour Logo
        cvUIImageToMat([UIImage imageNamed:@"ua_thick_60px"], logoImg_ua[0]); //60
        cv::cvtColor(logoImg_ua[0], logoImg_ua[0], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"ua_thick_80px"], logoImg_ua[1]); //80
        cv::cvtColor(logoImg_ua[1], logoImg_ua[1], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"ua_thick_100px"], logoImg_ua[2]); // 100
        cv::cvtColor(logoImg_ua[2], logoImg_ua[2], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"ua_thick_120px"], logoImg_ua[3]);
        cv::cvtColor(logoImg_ua[3], logoImg_ua[3], COLOR_BGR2GRAY);
        
        //        Nike Logo
        cvUIImageToMat([UIImage imageNamed:@"nike_logo_120px"], logoImg_nike[0]);
        cv::cvtColor(logoImg_nike[0], logoImg_nike[0], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"nike_logo_120px"], logoImg_nike[1]);
        cv::cvtColor(logoImg_nike[1], logoImg_nike[1], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"nike_logo_120px"], logoImg_nike[2]);
        cv::cvtColor(logoImg_nike[2], logoImg_nike[2], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"nike_logo_120px"], logoImg_nike[3]);
        cv::cvtColor(logoImg_nike[3], logoImg_nike[3], COLOR_BGR2GRAY);
        
        //        Wison Logo
        cvUIImageToMat([UIImage imageNamed:@"wilson_100px"], logoImg_wilson[0]);
        cv::cvtColor(logoImg_wilson[0], logoImg_wilson[0], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"wilson_110px"], logoImg_wilson[1]);
        cv::cvtColor(logoImg_wilson[1], logoImg_wilson[1], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"wilson_110px"], logoImg_wilson[2]);
        cv::cvtColor(logoImg_wilson[2], logoImg_wilson[2], COLOR_BGR2GRAY);
        cvUIImageToMat([UIImage imageNamed:@"wilson_110px"], logoImg_wilson[3]);
        cv::cvtColor(logoImg_wilson[3], logoImg_wilson[3], COLOR_BGR2GRAY);
        
        //        Spalding Logo
        cvUIImageToMat([UIImage imageNamed:@"spalding_120px"], logoImg_spalding[0]);
        cv::cvtColor(logoImg_spalding[0], logoImg_spalding[0], COLOR_BGR2GRAY);
        
        
        
        logoImages.push_back(logoImg_ua);
        logoImages.push_back(logoImg_nike);
        //        logoImages.push_back(logoImg_wilson);
        logoImages.push_back(logoImg_spalding);
        self.brandStrings = [[NSMutableArray alloc]initWithArray:@[@"Under Armour",@"Nike",@"Wilson",@"Spalding"]];
        self.brandStrings = [[NSMutableArray alloc]initWithArray:@[@"Under Armour",@"Nike",@"Spalding"]];
    }
    return self;
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

static void cvUIImageToMat(const UIImage* image, cv::Mat& m) {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width, rows = image.size.height;
    m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    CGContextRef contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8, m.step[0], colorSpace, kCGImageAlphaNoneSkipLast |kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    //    CGColorSpaceRelease(colorSpace);
}


-(UIImage*)processImage:(UIImage*)img debug:(BOOL) deb values:(NSArray*) val{
    
    Global *global = [Global sharedManager];
    
    RNG rng(12345);
    cv::Mat image;
    
    cvUIImageToMat(img, image);
    cv::flip(image, image, 1);
    UIImage*resultImage;
    
    switch (global.STATE) {
        case 1:// Logo Detection
            resultImage = [self search:image];
            break;
        case 2: // Ball Tracking
            resultImage = [self.personTracker Track:image];
            break;
        case 3: // Analytics
            // TODO: Quit the Image Processing thing
            
            // Show a new View Controller, the Analytics view
            break;
        case 7:
            //            resultImage = [ballTracker errorTrack];
            break;
        case 8:
            resultImage = [self findPerson:image];
            break;
        case 9:
            resultImage = [self.personTracker Track:image];
            break;
        default:
            //            notifyHandler "Error Lighting"
            break;
    }
    
    
    return resultImage;
}

-(UIImage*)findPerson:(cv::Mat)image{
    cv::Mat imgHSV;
    cv::cvtColor(image, imgHSV, COLOR_RGB2HSV);
    [self determineColorOfShirt:image];
    
    
    UIImage * test = cvMatToUIImage(image);
    //    UIImage * test = deb ? cvMatToUIImage(image) :  cvMatToUIImage(image2);
    image.release();
    imgHSV.release();
    
    return test;
}

-(UIImage*)search:(cv::Mat)image{
    
    int screenWidth = image.cols, screenHeight = image.rows;
    /// CODE STARTS HERE!!
    
    // Convert to Gray Scale
    
    cv::Mat img_scene;
    cv::cvtColor(image, img_scene, COLOR_BGR2GRAY);
    
    // Crop the Image Frame
    
    //    CGSize screenSize =   [[UIScreen mainScreen]bounds].size;
    
    // For 640
    //   cv::Rect roi = cv::Rect( (int) (screenWidth/2)-100, (int) (screenHeight /2)- 100, 200,200);
    
    NSLog(@"ROI W=%d , H=%d " ,(int) (screenWidth/2), (int) (screenHeight /2) );
    // 176, 144
    
    // for 352
    // minimum value width is 120 for 352x288
    
    cv::Rect roi = cv::Rect( (int) (screenWidth/2)-100, (int) (screenHeight /2)-100, 150,150);
    // Top Left Corner is X,Y
    
    
    
    cv::Mat cropImg = cv::Mat(img_scene, roi);
    
    
    // Perform canny and clean up the frame for logo detection
    LogoFilter(cropImg);
    // Cleans up the Logo Area and Amplifies it
    
    
    
    cv::Point matchLoc = cv::Point(-1,-1);
    int response[3];
    
    // Variables that will hold the selected logo info
    String chosenBrand="";
    int chosenLogo = -1;
    cv::Mat chosenLogoMat;
    
    for (int i=0; i < logoImages.size() ;i++) { // For each Brand
        
        
        SearchLogoBrand(cropImg, logoImages[i], response, i);// Search for logo of this brand
        chosenLogo = response[0]; // response[0] is the chosenLogo's id. Returns -1 if no logo detected for this brand
        if (chosenLogo != -1) { // if a logo was detected
            
            chosenBrand = brandString[i]; // chosenBrand is this one
            chosenLogoMat = logoImages[i][chosenLogo]; // chosenLogo Mat is this logo Mat
            matchLoc.x = response[1]; // X coordinate of logo detected on screen
            matchLoc.y = response[2]; // Y coordinate of logo detected on screen
            break;
        } //end if logo was detected
    }
    
    [self processLogoMatch:image rect:roi point:matchLoc logo:chosenLogoMat];
    
    // If a logo was detected
    if (matchLoc.x != -1){
        // Process the Logo Match to determine ball color characteristics
        [self processLogoMatch:image rect:roi point:matchLoc logo:chosenLogoMat];
        //        processLogoMatch(image, roi, matchLoc, chosenLogoMat);
        
        cv::putText(image, chosenBrand + ":" + std::to_string(chosenLogo) , cv::Point(60,90), FONT_HERSHEY_DUPLEX, 2, Scalar(0,0,0));
        cv::putText(img_scene, chosenBrand + ":" + std::to_string(chosenLogo) , cv::Point(60,90), FONT_HERSHEY_DUPLEX, 2, Scalar(0,0,0));
    }else{
        clear_logoDetectDuration();
    }
    
    
    
    UIImage * test = cvMatToUIImage(image);
    //    UIImage * test = deb ? cvMatToUIImage(image) :  cvMatToUIImage(image2);
    image.release();
    img_scene.release();
    return test;
    
}
static void LogoFilter(cv::Mat cropImg){
    
    //    List<MatOfPoint> contours = new ArrayList<MatOfPoint>();
    // Canny // TODO: This is absolute
    cv::Canny(cropImg, cropImg, 70,210);         // Edge detection  was 50, 150
    // Find Contours
    vector<vector<cv::Point> > contours;
    
    
    /// Detect edges using Threshold
    
    /// Find contours
    cv::findContours( cropImg, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    
    //    cv::findContours(cropImg, contours, new cv::Mat(), RETR_TREE, CHAIN_APPROX_SIMPLE);
    // Draw A Line Around the Contours
    for (int i = 0; i < contours.size(); i++){ // for each contour
        cv::drawContours(cropImg , contours, i, cv::Scalar(255), 5);
    } //end for all contours
    
}

static void SearchLogoBrand( cv::Mat cropImg, cv::Mat *logoImg_arr, int* response, int imageBrand){
    cv::Point matchLoc = cv::Point(-1,-1);
    
    int chosenLogo = -1;
    int arrSize;
    switch (imageBrand) {
        case 0:
            arrSize = 4;
            break;
        case 1:
            arrSize = 4;
            break;
        case 2:
            //            arrSize = 4;
            arrSize = 1;
            break;
        case 3:
            arrSize = 1;
            break;
        default:
            arrSize = 1;
            break;
    }
    
    
    for(int i=0; i< arrSize ; i++){
        // Find Logo Match in Image
        matchLoc = findLogoMatch(cropImg, logoImg_arr[i], imageBrand);
        if (matchLoc.x != -1){
            chosenLogo = i;
            break;
        }
    }
    response[0] = chosenLogo;
    response[1] = (int) matchLoc.x;
    response[2] = (int) matchLoc.y;
    
    
    
}


-(void)  determineColorOfShirt:(cv::Mat) img {
    
    cv::Mat imgHSV;
    cv::cvtColor(img , imgHSV, cv::COLOR_RGB2HSV);
    
    int screenWidth = img.cols;
    int screenHeight = img.rows;
    
    std::vector<int> H_List;
    
    for ( int y = 0; y < screenHeight - 1; y++ ){
        for ( int x = 0; x < screenWidth - 1; x++ ){
            Vec3b hsvValue = imgHSV.at<Vec3b>(x, y);
            int H = hsvValue.val[0];  // = imgHSV.get(y,x)[0];
            int S = hsvValue.val[1];  // = imgHSV.get(y, x)[1];
            int V = hsvValue.val[2];  // = imgHSV.get(y, x)[2];
            
            //            NSLog(@"HSV - %d:%d:%d", H, S, V);
            if (S > 255 / 2 && V > 255 / 2){
                H_List.push_back(H);
            }
            
            
            
        }
    }
    NSLog(@"HList size  - %d",H_List.size());
    for (int i = 0; i < H_List.size() / 20; i = i + 20){
        //        NSLog(@"HVAls - %d",H_List[i]);
    }
    
    int * H_mode = histog(H_List, 90, 2);
    
    int * H_range = calc_rangeValue( H_mode, 0.7, 2, 90); // returns the [lower_range_limit, higher_range_limit]
    NSLog(@"H Range - %d - %d", H_range[0], H_range[1]);

    vector<int>().swap(H_List);
    H_mode = 0;
    
    
    Global *global = [Global sharedManager];
    global.minH = H_range[0];
    global.maxH = H_range[1];
    
    int S_range[2];
    S_range[0] = 256/2;
    S_range[1] = 250;
    int V_range[2];
    V_range[0] = 256/2;
    V_range[1] = 255;
    
    [self setColorSpectrumRange:H_range withS:S_range withV:V_range];
    imgHSV.release();
}



//-(void)processLogoMatch:(cv::Mat) img rect:(cv::Rect) roi point:(cv::Point) matchLoc logo:(cv::Mat) logoImg{
//
//}
//void processLogoMatch( cv::Mat img, cv::Rect roi, cv::Point matchLoc, cv::Mat logoImg ){
-(void)processLogoMatch:(cv::Mat) img rect:(cv::Rect) roi point:(cv::Point) matchLoc logo:(cv::Mat) logoImg{
    
    
    // Calculate the left and right corner positions of the bounding box around the logo
    cv::Point logoCorner1(matchLoc.x + roi.x, matchLoc.y+roi.y); /// TODO: WAIT ISN"T ROI.X THE TOP CORNER
    cv::Point logoCorner2(logoCorner1.x + logoImg.cols, logoCorner1.y + logoImg.rows );
    
    // Draw a Rectangle around the Match
    cv::Scalar rectangle_color(0, 255, 0);
    int rectangle_thickness = 10;
    
    
    
    double logoDuration = logoDetectDuration();
    // if the Logo was detected for longer than the predefined Threshold time
    if( logoDuration >= 0 ){
        NSLog(@"LONGER THAN THRESHOLD");
        
        // if the log was detected for longer thn the predefined Threshold time
        // then lets process the frame to learn what color range the ball is
        
        // Convert the image frame to HSV format
        cv::Mat imgHSV;
        cv::cvtColor(img , imgHSV, cv::COLOR_RGB2HSV);
        
        // Calculate the center position of the detected logo
        cv::Point circleCenter( logoCorner1.x + (logoImg.cols/2), logoCorner1.y + (logoImg.rows/2) );
        
        
        // Future code, leave commented
        
        
        // TODO: Circle Radius should be a function of logo size, but for now its constant
        int circleRadius = 120; //was 100
        int screenWidth = img.cols;
        int screenHeight = img.rows;
        
        // Define variables to keep track of ball Area pixels and rejected pixels
        long ballArea = 0;
        long rejectedPixels = 0;
        
        //Define Arrays to hold data about each pixel of the ball
        //        int pixel[0]; //vd: Size is 0 but gotta change
        std::vector<int*> pixel;
        
        //Define an Array of integers to hold all the H values detected in the ball Area
        //        int H_List[0]; //vd: Size is 0 but gotta change
        std::vector<int> H_List;
        // Circle through every single pixel detected in the ball
        for ( int y = 0; y < screenHeight - 1; y++ ){
            for ( int x = 0; x < screenWidth - 1; x++ ){
                
                // If the pxel is inside the circle drawn around the center of the detected logo
                if( isInCircle(cv::Point(x,y), circleCenter, circleRadius) ){ //vd: NEED TO DEFINE A FUNCTION HERE
                    
                    Vec3b hsvValue = imgHSV.at<Vec3b>(x, y);
                    // Store the H, S, V values of this pixel into seperate variables
                    
                    int H = hsvValue.val[0];  // = imgHSV.get(y,x)[0];
                    int S = hsvValue.val[1];  // = imgHSV.get(y, x)[1];
                    int V = hsvValue.val[2];  // = imgHSV.get(y, x)[2];
                    //                    NSLog(@"H - %d  S - %d  V -  %d",H,S,V);
                    // if the Color is within the Bounds of Reasonable color
                    // meaning the color isn't white or yellow or anything
                    if( isBallColor(H, S, V) ){ // Within the possible HSV value for the ball color
                        ballArea++;
                        
                        // H in openCV is weird, you need to wrap it around by 90
                        // e.g.  91 becomes 1, 100 becomes 10  BUT 89 stays 89, 35 stays 35
                        //                        if( H >= 90 ){
                        //                            H = H-90;
                        //                        }
                        //                        else{
                        //                            H = H+90;
                        //                        }
                        
                        //Append this Pixel's color value to the Pixel Array
                        int* hsv = new int [3];
                        hsv[0] = H;
                        hsv[1] = S;
                        hsv[2] = V;
                        pixel.push_back(hsv);
                        //*************DJFHDSJFHSDJFHDFJHDS//////
                        // append the H value to the H list array
                        
                        //                        if (S > 256 / 2 && V > 256 / 2){
                        H_List.push_back(H);
                        //                        }
                    }
                    else{ // if this pixel is not a possible color on the ball (e.g. black, blue, white)
                        rejectedPixels += 1; // increment the rejected pixels count
                    } // else
                } // if pixel inside the circle
            } // for every pixel in row
        } //for every row in a frame
        
        
        //        NSLog(@"Ball Area - %ld",ballArea);
        //        NSLog(@"Rejected Pixels - %ld",rejectedPixels);
        
        imgHSV.release(); // release this Mat, we're not using it anymore
        
        // Define constants
        double kH = 0.7;
        double kS = 0.15;
        double kV = 0.15;
        
        NSLog(@"Length =  %ld" , H_List.size() );
        
        
        // Calculate the Histogram for H values
        int * H_mode = histog( H_List, 90, 2 ); // returns histogram array
        
        for(int i = 0; i < 90; i++){
            //                        NSLog(@"H%d: %d",i,H_mode[i]);
        }
    
        int * H_range = calc_rangeValue( H_mode, kH, 2, 90); // returns the [lower_range_limit, higher_range_limit]
        NSLog(@"H Range - %d - %d", H_range[0], H_range[1]);
        
        
        // Debug output, range for H value is
        //        NSLog(@"");
        
        //Declare a List Array of integers to store information about the  S and V values int he ball
        //        int S_list[0];
        //        int V_List[0]; //vd: change this to mutable array
        std::vector<int> S_list;
        std::vector<int> V_list;
        std::vector<int> H_list;
        long s_sum = 0;
        
        //for every pixel
        for ( int i=0; i < pixel.size(); i++ ){
            
            int* hsv = pixel.at(i); //get the pixel's hsv array [h,s,v] //vd: change this to mutable array?
            int h = hsv[0]; //get the h value
            int s = hsv[1];
            int v = hsv[2];
            
            if( h >= H_range[0] && h <= H_range[1] ){ // if this pixel's h value is within H_range limits
                S_list.push_back(s);
                V_list.push_back(v);
                H_list.push_back(h);
                // APPEND s value to S_list array
                // APPEND v vale to V_list array
            }
            
            s_sum = s_sum + s;
        }
        Global *global = [Global sharedManager];
        
        global.S_mean = s_sum / pixel.size() ; //vd: might have to change this
        NSLog(@"S mean = %d", global.S_mean);
        
        
        // Calculate the histogram of the V values
        int * S_mode = histog(S_list, 256/8, 8); // get histogram for V values, divide values by 4
        int * mmS = find_peakValue(S_mode , 256 / 8);
        //        int mmS[] = std::find - peakValue(S_mode); //find the peak value
        global.peakS = mmS[0]*8;//this is the peak S value detected
        NSLog(@"Peak S = %d", global.peakS);
        
        
        for(int i = 0; i < 256/8; i++){
            //            NSLog(@"%d: %d",i*8,S_mode[i]);
        }
        
        
        
        int* S_range = calc_rangeValue(S_mode, kS , 8, 256/8);
        NSLog(@"S range = %d to %d", S_range[0],S_range[1]);
        
        //      // NOTE: ERIC I MANUALLY DID THIS, S_RANGE DOESNT WORK. TODO: FIX IT
        //      S_range[0] = 70;
        //      S_range[1] = 200;
        
        
        // Calculate the histogram of the V values
        
        int* V_mode = histog(V_list,256/8,8); // get histogram for V values, divide values by 4
        int* mmV = find_peakValue(V_mode , 256/8);	// find the peak Value
        global.V_limit = calc_rangeValue(V_mode,kV,8 , 256 / 8); // calculate the V range limits
        
        NSLog(@"V range = %d to %d", global.V_limit[0],global.V_limit[1]);
        
        
        NSLog(@"Peak V = %d", mmV[0]*8);
        NSLog(@"V MODE VALUES = ");
        
        
        for(int i = 0; i < 256/8; i++){
            //            NSLog(@"%d: %d",i*8,H_mode[i]);
        }
        
        
        // Arbitrarily set the V value range, brightness range
        int V_range[2];
        V_range[0] = 30;
        V_range[1] = 255;
        
        // set the global color spectrum range
        [self setColorSpectrumRange:H_range withS:S_range withV:V_range];
        //        setColorSpectrumRange( H_range, S_range, V_range );
        
        // Draw a circle arund where we think the ball is
        cv::circle(img, circleCenter, circleRadius, rectangle_color, rectangle_thickness);
        
        NSLog(@"lowerSpec= %d, %d, %d,  to %d, %d, %d, %d",global.LowerSpect[0],global.LowerSpect[1],global.LowerSpect[2],global.LowerSpect[4],global.LowerSpect[5],global.LowerSpect[6]);
        
        NSLog(@"upperSpect= %d, %d, %d, to %d, %d, %d",global.UpperSpect[0],global.UpperSpect[1],global.UpperSpect[2],global.UpperSpect[4],global.UpperSpect[5],global.UpperSpect[6]);
        
        
        // Update the Global state, Logo Detected so nect state should be Ball Tracking
        //        STATE = BALL_TRACKING;
        //        global.STATE = global.BALL_TRACKING;
        
        //DEBUGGING STUFF INCLUDE LATER WHEN THERE'S TIME
        
    } // end if LogoDetectCount >
    
    //Draw a black box around the Logo detection
    
    cv::rectangle(img, logoCorner1, logoCorner2, rectangle_color, rectangle_thickness, 0, 0);
} // end sub ProcessLogoMatch

static cv::Point findLogoMatch(cv::Mat cropImg, cv::Mat logoImg, int imageBrand) {
    // Search cropImg for logoImg
    /// Create the result matrix
    
    int result_cols =  cropImg.cols - logoImg.cols + 1; // was img_scene instead of cropImg
    int result_rows = cropImg.rows - logoImg.rows + 1;
    
    cv::Mat result;
    result.create(result_rows, result_cols, CV_32FC1);
    
    int match_method = 5;   // define Match Method for Logo Detection
    
    /// Do the Matching and Normalize
    
    double minVal; double maxVal; cv::Point minLoc; cv::Point maxLoc;
    cv::Point matchLoc;
    
    minMaxLoc( result, &minVal, &maxVal, &minLoc, &maxLoc, Mat() );
    
    int confidence =(int) (maxVal*100);
    
    cv::normalize( result, result, 0, 1, NORM_MINMAX, -1, Mat());
    
    minMaxLoc( result, &minVal, &maxVal, &minLoc, &maxLoc, Mat() );
    
    /// For SQDIFF and SQDIFF_NORMED, the best matches are lower
    /// For SQDIFF and SQDIFF_NORMED, the best matches are lower values. For all the other methods, the higher the better
    if( match_method  == TM_SQDIFF || match_method == TM_SQDIFF_NORMED )
    { matchLoc = minLoc; }
    else
    { matchLoc = maxLoc; }
    
    result.release();
    
    //    NSLog(@"Max Val = %f",maxVal);
    if(confidence > 30){
        NSLog(@"DETECTED %@, Confidence = %d", [NSString stringWithCString: brandString[imageBrand].c_str() encoding:[NSString defaultCStringEncoding]] ,confidence);
    }
    //    UIImage *testImage = cvMatToUIImage(logoImg);
    
    
    Global *g = [Global sharedManager];
    
    if (confidence > g.CONFIDENCE_THRESHOLD) {
        //        NSLog(@"LOGO %@ DETECTED",[NSString stringWithCString: brandString[imageBrand].c_str() encoding:[NSString defaultCStringEncoding]]);
        // Calculate the center point of the matching location
        return matchLoc;
    }
    else {
        return cv::Point(-1,-1);
    }
    
    
}

int* fit_Srange( int *S_range, int peakS ){
    // If the range S is too small
    
    
    if( S_range[0] >= peakS - 4 ){
        S_range[0] = peakS - 30;
    }
    if( S_range[1] >= peakS + 4){
        S_range[1] = peakS + 30;
    }
    
    int OFFSET = 50; // was 50
    //if the range of S is too wide
    if( S_range[0] < peakS - OFFSET ){
        S_range[0] = peakS - OFFSET;
    }
    if( S_range[1] < peakS + OFFSET ){
        S_range[1] = peakS + OFFSET;
    }
    if( S_range[1] < peakS + OFFSET ){
        S_range[1] = peakS + OFFSET;
    }
    if( S_range[1] < peakS + OFFSET ){
        S_range[1] = peakS + OFFSET;
    }
    return S_range;
}

void clear_logoDetectDuration(){
    first_timestamp = -1;
}

double logoDetectDuration(){
    double timestamp = CACurrentMediaTime();
    // get timestamp
    if( first_timestamp > 0 ){
        NSLog(@"timestamp  - %f", ( (timestamp - first_timestamp)) );
        return (timestamp - first_timestamp);
    }
    else{
        first_timestamp = timestamp;
        return 0;
    }
}

//-(void)setColorSpectrumRange:(int*)H_Range withS:(int*)S_range withV:(int*)V_range{
//void setColorSpectrumRange( int* H_range, int* S_range, int* V_range ){
-(void)setColorSpectrumRange:(int*)H_range withS:(int*)S_range withV:(int*)V_range{
    Global *global = [Global sharedManager];
    
    int H0 = H_range[0];
    int H1 = H_range[1];
    
    if( H0 >= 0 && H1 >=0 ){
        //same range
        global.LowerSpect = new int[8];
        global.UpperSpect = new int[8];
        Scalar a = Scalar(H0,S_range[0], V_range[0]);
        Scalar b = Scalar(H1, S_range[1], V_range[1]);
        
        global.LowerSpect[0] = a.val[0];
        global.LowerSpect[1] = a.val[1];
        global.LowerSpect[2] = a.val[2];
        global.LowerSpect[3] = a.val[3];
        global.LowerSpect[4] = b.val[0];
        global.LowerSpect[5] = b.val[1];
        global.LowerSpect[6] = b.val[2];
        global.LowerSpect[7] = b.val[3];
        
        Scalar c = Scalar( H1, S_range[0], V_range[0] );
        Scalar d = Scalar( H1, S_range[1], V_range[1] );
        
        global.UpperSpect[0] = c.val[0];
        global.UpperSpect[1] = c.val[1];
        global.UpperSpect[2] = c.val[2];
        global.UpperSpect[3] = c.val[3];
        global.UpperSpect[4] = d.val[0];
        global.UpperSpect[5] = d.val[1];
        global.UpperSpect[6] = d.val[2];
        global.UpperSpect[7] = d.val[3];
        
    }else{
        assert("BAD ERROR");
        
    }

}

bool isBallColor( int H, int S, int V  ){
    return ( (V<=254 && V>=30) && (H>=170 || H<=16) );
}

static int* calc_rangeValue( int* hist, double factor, int multiplier, int arrSize ){
    
    int* maxmax = find_peakValue(hist, arrSize);
    int mode_index = maxmax[0];
    int mode_val = maxmax[1];
    
    int threshold = mode_val * factor;
    int upper_index = mode_index;
    int lower_index = mode_index;
    
    int i = mode_index;
    while (hist[i] >= threshold && i<arrSize) {
        i += 1;
        upper_index = i;
    }
    
    i = mode_index;
    while (hist[i] >= threshold && i>= 0) {
        i = i-1;
        lower_index = i;
        if( i<0 ){
            break;
        }
    }
    int* limit  = new int[2];
    limit[0] = lower_index * multiplier;
    limit[1] = upper_index * multiplier;
    return limit;
}

static int* find_peakValue( int* data, int arrSize ){
    int argmax = - 1;
    int max = -1;
    for( int i=0; i< arrSize; i++ ){
        if (data[i] > max){
            max = data[i];
            argmax = i;
        }
    }
    
    int * result = new int[2];
    result[0] = argmax;
    result[1] = max;
    return result;
}

static int* histog( std::vector<int> myList, int max_int, int divider ){
    int* hist = new int[max_int];
    for( int i=0; i< max_int; ++i ){
        hist[i] = 0;
    }
    
    for( int i=0; i < myList.size(); i++ ){
        hist[ myList[i] / divider ] += 1;
        //        NSLog(@"hist: %d : %d :  %d", hist[myList[i] / divider], myList[i],i);
    }
    return hist;
}

bool isInCircle( cv::Point testLoc, cv::Point circleCenter, int circleRadius ){
    double distance = pow( (testLoc.x-circleCenter.x),2) + pow( (testLoc.y-circleCenter.y),2);
    distance = sqrt(distance);
    //	Log.d(TAG,"IsInCircle,  dist =" + Double.toString(distance) + " circRadius=" + Integer.toString(circleRadius)) ;
    
    if (distance <= circleRadius) { // its in the circle
        return true;
    }
    else {
        return false; // it ain't inside the circle
    }
}

+ (NSArray*) getColorAtPoint:(CGPoint) point fromImage:(UIImage*)img{
    double h,s,v;
    
    cv::Mat image;
    cvUIImageToMat(img, image);
    //Test code!! delete
    
    //    InputArray
    
    Vec3b color = image.at<Vec3b>(cv::Point(point.x,point.y));
    float r = color.val[0];
    float g = color.val[1];
    float b = color.val[2];
    NSLog(@"r:%f, g:%f, b:%f",r,g,b);
    //end
    cvtColor(image, image, cv::COLOR_BGR2HSV);
    
    color = image.at<Vec3b>(cv::Point(point.x,point.y));
    h = color.val[0];
    s = color.val[1];
    v = color.val[2];
    NSLog(@"h:%f, s:%f, v:%f",h,s,v);
    
    return @[[NSNumber numberWithDouble:h],[NSNumber numberWithDouble:s],[NSNumber numberWithDouble:v], [NSNumber numberWithDouble:r],[NSNumber numberWithDouble:g],[NSNumber numberWithDouble:b]];
}
-(void)clearTrackingDurations{
    clear_logoDetectDuration();
    [self.personTracker clearTrackingDuration];
}

@end
