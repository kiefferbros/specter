//
//  SPAmbientTrack.h
//  MonsterSoup
//
//  Created by Jonathan Kieffer on 3/28/11.
//  Copyright 2011 Kieffer Bros., LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import <CoreAudio/CoreAudioTypes.h>
#import "SPTypes.h"

@protocol SPAmbientTrackDelegate;
@interface SPAmbientTrack : NSObject <AVAudioPlayerDelegate> {
@private
    AVAudioPlayer               *_player;
    NSTimer                     *_fadeTimer;
    
    SPFloat                     _volume, _duckPercentage; 
    
    id <SPAmbientTrackDelegate> __unsafe_unretained _delegate;
    
    CGFloat                     _fadeStep;
    NSTimeInterval              _duckStartTime, _fadeInterval;
    SEL                         _fadeSelector;
}
@property (nonatomic, readonly) SPFloat currentVolume; // the actual volume value of the track
@property (nonatomic, assign) SPFloat volume;  // goal volume for fading in and fading up
@property (nonatomic, unsafe_unretained) id <SPAmbientTrackDelegate> delegate;
@property (nonatomic, assign) NSInteger numberOfLoops;
@property (nonatomic, assign) SPFloat currentTime;
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign) SPFloat duckPercentage;
@property (nonatomic, readonly, getter=isFading) BOOL fading;

- (void)loadFileNamed:(NSString*)fileName;

- (void)play;
- (void)playAfterDelay:(NSTimeInterval)delay;
- (void)pause;
- (void)stop;
- (void)fadeIn;
- (void)fadeOut;
- (void)fadeUp;

- (void)fadeInOverInterval:(NSTimeInterval)interval;
- (void)fadeOutOverInterval:(NSTimeInterval)interval;
- (void)fadeUpOverInterval:(NSTimeInterval)interval;
- (void)duckOverInterval:(NSTimeInterval)interval;

@end

@protocol SPAmbientTrackDelegate <NSObject>
@optional
- (void)ambientTrackDidFadeOut:(SPAmbientTrack*)track;
- (void)ambientTrackDidFinishPlaying:(SPAmbientTrack*)track;
@end