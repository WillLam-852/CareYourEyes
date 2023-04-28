#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@class Landmark;
@class HolisticTracker;

@protocol HolisticTrackerDelegate <NSObject>
- (void)holisticTracker: (HolisticTracker *)tracker didOutputPoseLandmarks: (NSArray<Landmark *> *)poseLandmarks timestamp: (CMTime)time;
- (void)holisticTracker: (HolisticTracker *)tracker didOutputFaceLandmarks: (NSArray<Landmark *> *)faceLandmarks timestamp: (CMTime)time;
- (void)holisticTracker: (HolisticTracker *)tracker didOutputLeftHandLandmarks: (NSArray<Landmark *> *)leftHandLandmarks timestamp: (CMTime)time;
- (void)holisticTracker: (HolisticTracker *)tracker didOutputRightHandLandmarks: (NSArray<Landmark *> *)rightHandLandmarks timestamp: (CMTime)time;
- (void)holisticTracker: (HolisticTracker *)tracker didOutputPixelBuffer: (CVPixelBufferRef)pixelBuffer;
@end

@interface HolisticTracker : NSObject
- (instancetype)init;
- (void)startGraph;
- (double)sendPixelBuffer:(CVPixelBufferRef)pixelBuffer timestamp:(CMTime)timestamp;
- (void)setTimeScale:(CMTimeScale)newTimescale;
- (void)resetTimestamp;
- (void)advanceTimestamp;
@property (weak, nonatomic) id <HolisticTrackerDelegate> delegate;
@property int timescale;
@end

@interface Landmark: NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@property(nonatomic, readonly) float vis;
@property(nonatomic, readonly) float pres;
@end
