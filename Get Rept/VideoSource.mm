//
//  VideoSource.m
//

#import "VideoSource.h"

@interface VideoSource () <AVCaptureVideoDataOutputSampleBufferDelegate>

@end

@implementation VideoSource

-(id) init{
    if(self = [super init]){
        AVCaptureSession * captureSession = [[AVCaptureSession alloc] init];
        if ( [captureSession canSetSessionPreset:AVCaptureSessionPreset352x288] ) {
            [captureSession setSessionPreset:AVCaptureSessionPreset352x288];
            NSLog(@"Capturing video at 352x288");
        } else {
            NSLog(@"Could not configure AVCaptureSession video input");
        }
        _captureSession = captureSession;
        
    }
    return self;
}

- (void)dealloc {
    [_captureSession stopRunning];
}

- (AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice * device in devices ) {
        if ( [device position] == position ) {
            return device;
        }
    }
    return nil;
}

- (BOOL)startWithDevicePosition:(AVCaptureDevicePosition)devicePosition {
    // (1) Find camera device at the specific position
    AVCaptureDevice * videoDevice = [self cameraWithPosition:devicePosition];
    
    if ( !videoDevice ) {
        NSLog(@"Could not initialize camera at position %ld", (long)devicePosition);
        return FALSE;
    }
    
//    [self configureCameraForHighestFrameRate:videoDevice];
    
    // (2) Obtain input port for camera device
    NSError * error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if ( !error ) {
        [self setDeviceInput:videoInput];
    } else {
        NSLog(@"Could not open input port for device %@ (%@)", videoDevice, [error localizedDescription]);
        return FALSE;
    }
    
    // (3) Configure input port for captureSession
    if ( [self.captureSession canAddInput:videoInput] ) {
        [self.captureSession addInput:videoInput];
    } else {
        NSLog(@"Could not add input port to capture session %@", self.captureSession);
        return FALSE;
    }
    
    // Eric's experimental, lock the White Balance
    [self.deviceInput.device lockForConfiguration:nil];
    [self.deviceInput.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
    [self.deviceInput.device unlockForConfiguration];
    
    //Frame Rate boost
//    for(AVCaptureDeviceFormat *vFormat in [videoDevice formats] )
//    {
//        CMFormatDescriptionRef description= vFormat.formatDescription;
//        float maxrate=((AVFrameRateRange*)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
//        NSLog(@"Max Rate - %f",maxrate);
//        if(maxrate>59 && CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
//        {
//            if ( YES == [videoDevice lockForConfiguration:NULL] )
//            {
//                videoDevice.activeFormat = vFormat;
//                [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(10,600)];
//                [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(10,600)];
//                [videoDevice unlockForConfiguration];
//                NSLog(@"formats  %@ %@ %@",vFormat.mediaType,vFormat.formatDescription,vFormat.videoSupportedFrameRateRanges);
//            }
//        }
//    }
    
    
    
    // (4) Configure output port for captureSession
    [self addVideoDataOutput];
    
    // (5) Start captureSession running
    [self.captureSession startRunning];
    
//    AVCaptureConnection *connection = [[AVCaptureConnection alloc] initWithInputPorts:[[[self.captureSession inputs] firstObject] ports] output:[[self.captureSession outputs] firstObject]];
//    [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
//
    return TRUE;
}


- (void)configureCameraForHighestFrameRate:(AVCaptureDevice *)device
{
    AVCaptureDeviceFormat *bestFormat = nil;
    AVFrameRateRange *bestFrameRateRange = nil;
    for ( AVCaptureDeviceFormat *format in [device formats] ) {
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
                bestFormat = format;
                bestFrameRateRange = range;
            }
        }
    }
    if ( bestFormat ) {
        if ( [device lockForConfiguration:NULL] == YES ) {
            device.activeFormat = bestFormat;
            device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
            device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
            NSLog(@"%@",bestFrameRateRange);
            [device unlockForConfiguration];
        }
    }
}

- (void) addVideoDataOutput {
    // (1) Instantiate a new video data output object
    AVCaptureVideoDataOutput * captureOutput = [[AVCaptureVideoDataOutput alloc] init];
//    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    // (2) The sample buffer delegate requires a serial dispatch queue
    dispatch_queue_t queue;
    queue = dispatch_queue_create("com.YosephRadding.find.opencv", DISPATCH_QUEUE_SERIAL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
//    dispatch_release(queue);
    
    // (3) Define the pixel format for the video data output
    NSString * key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber * value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary * settings = @{key:value};
    [captureOutput setVideoSettings:settings];
    [captureOutput setAlwaysDiscardsLateVideoFrames:YES];
    // (4) Configure the output port on the captureSession property
    [self.captureSession addOutput:captureOutput];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    // (1) Convert CMSampleBufferRef to CVImageBufferRef
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // (2) Lock pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    // (3) Construct VideoFrame struct
    uint8_t *baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t stride = CVPixelBufferGetBytesPerRow(imageBuffer);
    VideoFrame frame = {width, height, stride, baseAddress};
    
    // (4) Dispatch VideoFrame to VideoSource delegate
    [self.delegate frameReady:frame];
    
    // (5) Unlock pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}


-(void) toggleFlashLight{
    if(self.deviceInput.device.torchMode == AVCaptureTorchModeOff){
        [self.deviceInput.device lockForConfiguration:nil];
        [self.deviceInput.device setTorchMode:AVCaptureTorchModeOn];
        [self.deviceInput.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
    }
    else{
        [self.deviceInput.device setTorchMode:AVCaptureTorchModeOff];
        [self.deviceInput.device unlockForConfiguration];
        
    }
}

@end
