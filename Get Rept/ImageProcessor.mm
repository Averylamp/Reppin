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
        case 2:
            resultImage = [self.personTracker Track:image];
            break;
        case 3: // Analytics
            // TODO: Quit the Image Processing thing
            
            // Show a new View Controller, the Analytics view
            break;
        case 8:
            resultImage = [self findPerson:image];
            break;
        case 9:
            global.currentRepCount = 0;
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
    

    /// CODE STARTS HERE!!
    
    // Convert to Gray Scale
    
    cv::Mat img_scene;
    cv::cvtColor(image, img_scene, COLOR_BGR2GRAY);
    
    
    UIImage * test = cvMatToUIImage(image);
    //    UIImage * test = deb ? cvMatToUIImage(image) :  cvMatToUIImage(image2);
    image.release();
    img_scene.release();
    return test;
    
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
    NSLog(@"HList size  - %lu",H_List.size());
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

void clear_DetectDuration(){
    first_timestamp = -1;
}

double detectDuration(){
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


-(void)clearTrackingDurations{
    clear_DetectDuration();
    [self.personTracker clearTrackingDuration];
}

@end
