//
//  Audio.h
//  MonsterSoup
//
//  Created by Jonathan Kieffer on 3/25/11.
//  Copyright 2011 Kieffer Bros., LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#import "SPAmbientTrack.h"
#endif
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#import "SPSound.h"


extern NSString *const SPAudioWillBeginInterruptionNotification;
extern NSString *const SPAudioDidEndInterruptionNotification;
extern NSString *const SPAudioDidChangeMusicEnabledNotification;
extern NSString *const SPAudioDidChangeSoundsEnabledNotification;

//@protocol SPAudioDelegate;

@interface SPAudio : NSObject {    
@private
	ALCdevice *_device;
	ALCcontext *_context;
    
    BOOL _musicEnabled, _soundsEnabled;
    
//    id <SPAudioDelegate> __unsafe_unretained _delegate;
}
@property (readonly, nonatomic) ALCcontext *alContext;
@property (nonatomic, assign) BOOL soundsEnabled, musicEnabled;
//@property (nonatomic, unsafe_unretained) id <SPAudioDelegate> delegate;
+ (SPAudio*)sharedAudio;

- (void)makeALContextCurrent:(BOOL)makeCurrent;
- (void)suspendALContext;
- (void)processALContext;

#if TARGET_OS_IPHONE
// audio sessions
- (BOOL)isOtherAudioPlaying;
#endif
@end

/*
@protocol SPAudioDelegate <NSObject>
@optional
#if TARGET_OS_IPHONE
- (void)audioWillBeginInterruption:(SPAudio*)audio;
- (void)audioDidEndInterruption:(SPAudio*)audio;
#endif
- (void)audioDidChangeMusicEnabled:(SPAudio*)audio;
- (void)audioDidChangeSoundsEnabled:(SPAudio*)audio;
@end*/
