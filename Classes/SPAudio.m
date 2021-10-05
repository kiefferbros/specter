//
//  SPAudio.m
//  Specter
//
//  Created by Jonathan Kieffer on 3/25/11.
//  Copyright 2011 Kieffer Bros., LLC. All rights reserved.
//

#import "SPAudio.h"
#import <AudioToolbox/AudioToolbox.h>

#if TARGET_OS_IPHONE
@interface SPAudio ()
- (void)endInterruption;
@end
#endif

NSString *const SPAudioWillBeginInterruptionNotification = @"SPAudioWillBeginInterruptionNotification";
NSString *const SPAudioDidEndInterruptionNotification = @"SPAudioDidEndInterruptionNotification";
NSString *const SPAudioDidChangeMusicEnabledNotification = @"SPAudioDidChangeMusicEnabledNotification";
NSString *const SPAudioDidChangeSoundsEnabledNotification = @"SPAudioDidChangeSoundsEnabledNotification";

NSString *const SPSoundsEnabledKey = @"SPSoundsEnabledKey";
NSString *const SPMusicEnabledKey = @"SPMusicEnabledKey";

static SPAudio *_sharedAudio;

@implementation SPAudio
@synthesize alContext=_context;
@synthesize soundsEnabled=_soundsEnabled;
@synthesize musicEnabled=_musicEnabled;
//@synthesize delegate=_delegate;

+ (SPAudio*)sharedAudio {
    if (!_sharedAudio)
        _sharedAudio = [[SPAudio alloc] init];
    
    return _sharedAudio;
}

- (id)init {
    if ((self = [super init])) {
#if TARGET_OS_IPHONE
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
            [nc addObserver:self selector:@selector(appDidEnterBG:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [nc addObserver:self selector:@selector(appWillEnterFG:) name:UIApplicationWillEnterForegroundNotification object:nil];
        }
        
        // step up the iOS audio session
        //[[AVAudioSession sharedInstance] setDelegate:self];
       // [[AVAudioSession sharedInstance] ha]
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
#endif
        
        // set up OpenAL
        // clear the errors
		alGetError();
		
		// connect to the default device
		_device = alcOpenDevice(NULL);
		
		if (!_device) {
			NSLog(@"Error opening OpenAL device.");
			return nil;
		}
		
		// create a context to render the sound to
		_context = alcCreateContext(_device, NULL);
        
		if (!_context) {
			NSLog(@"Error creating OpenAL context.");
			return nil;
		}
		
		// set the current context
		alcMakeContextCurrent(_context);
		
		ALenum error = alGetError();
		if (error != AL_NO_ERROR) {
			NSLog(@"Error setting OpenAL context");
			return nil;
		}
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _soundsEnabled = [defaults objectForKey:SPSoundsEnabledKey]!=nil ? [defaults boolForKey:SPSoundsEnabledKey] : YES;
        _musicEnabled = [defaults objectForKey:SPMusicEnabledKey]!=nil ? [defaults boolForKey:SPMusicEnabledKey] : YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_context) alcDestroyContext(_context);
	if (_device) alcCloseDevice(_device);
}

#if TARGET_OS_IPHONE

#pragma mark -
#pragma mark Notifications

- (void)appDidEnterBG:(NSNotification*)note {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    [self suspendALContext];
	[self makeALContextCurrent:NO];
}

- (void)appWillEnterFG:(NSNotification*)note {
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    [self makeALContextCurrent:YES];
    [self processALContext];
}

#pragma mark -
#pragma mark AVAudioSessionDelegate
- (void)beginInterruption {   
    //if (self.delegate && [self.delegate respondsToSelector:@selector(audioWillBeginInterruption:)])
     //   [self.delegate audioWillBeginInterruption:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SPAudioWillBeginInterruptionNotification object:self];
    
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    [self suspendALContext];
	[self makeALContextCurrent:NO];
}

- (void)endInterruption {
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    [self makeALContextCurrent:YES];
    [self processALContext];
    
    //if (self.delegate && [self.delegate respondsToSelector:@selector(audioDidEndInterruption:)])
    //[self.delegate audioDidEndInterruption:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:SPAudioDidEndInterruptionNotification object:self];
    
}

// 4.0 and later
- (void)endInterruptionWithFlags:(NSUInteger)flags {
    [self endInterruption];
}

#pragma mark -
#pragma mark Audio Settings
- (BOOL)isOtherAudioPlaying {
	return [[AVAudioSession sharedInstance] isOtherAudioPlaying];
}
#endif

- (void)setSoundsEnabled:(BOOL)enabled {
    _soundsEnabled = enabled;
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SPSoundsEnabledKey];
    //if (self.delegate && [self.delegate respondsToSelector:@selector(audioDidChangeSoundsEnabled:)])
    //    [self.delegate audioDidChangeSoundsEnabled:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SPAudioDidChangeSoundsEnabledNotification object:self];
}

- (void)setMusicEnabled:(BOOL)enabled {
    _musicEnabled = enabled;
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SPMusicEnabledKey];
    //if (self.delegate && [self.delegate respondsToSelector:@selector(audioDidChangeMusicEnabled:)])
    //    [self.delegate audioDidChangeMusicEnabled:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SPAudioDidChangeMusicEnabledNotification object:self];
}

#pragma mark -
#pragma mark OpenAL
- (void)makeALContextCurrent:(BOOL)makeCurrent {
    alGetError();
	alcMakeContextCurrent((makeCurrent)?self.alContext:NULL);
}

- (void)suspendALContext {
	alcSuspendContext(self.alContext);
}

- (void)processALContext {
	alcProcessContext(self.alContext);
}
@end
