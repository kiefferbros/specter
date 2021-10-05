//
//  SPAmbientTrack.m
//  MonsterSoup
//
//  Created by Jonathan Kieffer on 3/28/11.
//  Copyright 2011 Kieffer Bros., LLC. All rights reserved.
//

#import "SPAmbientTrack.h"

#define kStepRate 15.f // steps per second

NSString *kStepKey = @"Step";
NSString *kInvocationKey = @"Invocation";

@interface SPAmbientTrack ()
- (void)startFadeTimer;
@end

@implementation SPAmbientTrack

- (id)init {
    if ((self = [super init])) {
        _volume = 1.;
        _duckPercentage = 0.5;
    }
    return  self;
}

- (void)dealloc {
    [_fadeTimer invalidate];
}

- (void)loadFileNamed:(NSString*)fileName {
    _player = nil;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (path == nil) {
        NSLog(@"error loading track: %@", fileName);
		return;
    }
    NSURL *url = [NSURL fileURLWithPath:path];
	
    _player = nil;
	if (!(_player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil])) {
		NSLog(@"error loading track: %@", fileName);
		return;
	}
    
    [_player prepareToPlay];
    _player.volume = _volume;
	
	_player.delegate = self;
}

#pragma mark -
#pragma mark Info
- (BOOL)isFading {
    return (_fadeTimer != nil);
}

@dynamic currentVolume;
@synthesize volume=_volume;  
@synthesize duckPercentage=_duckPercentage;
@synthesize delegate=_delegate;
@dynamic numberOfLoops;
@dynamic currentTime;
@dynamic playing;

#pragma mark -
#pragma Transport

- (void)play {
    if (_fadeSelector != NULL) {
        [self startFadeTimer];
    } else {
        _player.volume = _volume;
    }
	[_player play];
}

- (void)playAfterDelay:(NSTimeInterval)delay {
    _player.volume = _volume;
    if ([_player respondsToSelector:@selector(playAtTime:)])
        [_player playAtTime:_player.deviceCurrentTime+delay];
    else
        [_player performSelector:@selector(play) withObject:nil afterDelay:delay];
}

- (void)pause {
    if (_player.isPlaying) {
        if (_fadeTimer) {
            // save fade time info for resuming play
            if (_fadeSelector == @selector(_finishDucking:)) {
                _fadeInterval = CFAbsoluteTimeGetCurrent() - _duckStartTime;
            }
            
            [_fadeTimer invalidate];
            _fadeTimer = nil;
        }
        [_player pause];
    }
}

- (void)stop {
    [_fadeTimer invalidate];
	_fadeTimer = nil;
    _fadeSelector = NULL;
    [_player stop]; 
}

- (void)setCurrentTime:(SPFloat)currentTime {
    _player.currentTime = currentTime;
}

- (SPFloat)currentTime {
    return _player.currentTime;
}

- (void)setNumberOfLoops:(NSInteger)numberOfLoops {
    _player.numberOfLoops = numberOfLoops;
}

- (NSInteger)numberOfLoops {
    return _player.numberOfLoops;
}

- (BOOL)isPlaying {
    return _player.isPlaying;
}

- (SPFloat)currentVolume {
    return _player.volume;
}

- (void)setVolume:(SPFloat)volume  {
    _volume = volume;
    _player.volume = volume;

}

#pragma mark -
#pragma Fading
- (void)fadeIn {
    [self fadeInOverInterval:1.];
}

- (void)fadeOut {
    [self fadeOutOverInterval:1.];
}

- (void)fadeUp {
    [self fadeUpOverInterval:0.5];
}

- (void)fadeInOverInterval:(NSTimeInterval)interval {
    if (_player == nil) return;
	
	float step = _volume/(interval*kStepRate);
    
	_player.volume = 0.0;
	[_player play];
    
    _fadeStep = step;
    _fadeInterval = 1.0/kStepRate;
    _fadeSelector = @selector(_fadeIn:);
    
	[self startFadeTimer];
}

- (void)fadeUpOverInterval:(NSTimeInterval)interval {
    if (!_player.isPlaying || _player == nil) return;
    
	float step = (_volume - _player.volume)/(interval*kStepRate);
	
    _fadeInterval = 1.f/kStepRate;
    _fadeSelector = @selector(_fadeIn:);
    _fadeStep = step;
    
	[self startFadeTimer];
}

- (void)_fadeIn:(NSTimer*)timer {
	float vol = _player.volume + [(NSNumber*)[timer userInfo] floatValue];
	
	if (_player.volume >= _volume || !_player.isPlaying) {
        _fadeSelector = NULL;
		[timer invalidate];
		_fadeTimer = nil;
        
		vol = _volume;
	}
	
	_player.volume = vol;
}

- (void)fadeOutOverInterval:(NSTimeInterval)interval {
    if (!_player.isPlaying || _player == nil) return;
	
	float step = _player.volume/(interval*kStepRate);
	
    _fadeInterval = 1.f/kStepRate;
    _fadeSelector = @selector(_fadeOut:);
    _fadeStep = step;
    
	[self startFadeTimer];

}

- (void)_fadeOut:(NSTimer*)timer {
	_player.volume -= [(NSNumber*)[timer userInfo] floatValue];
	if (_player.volume <= 0.0 || !_player.isPlaying) {
        _fadeSelector = NULL;
		[timer invalidate];
        _fadeTimer = nil;
		[_player stop];
		
        
		if (self.delegate && [self.delegate respondsToSelector:@selector(ambientTrackDidFadeOut:)])
			[self.delegate ambientTrackDidFadeOut:self];
	}
}

- (void)startFadeTimer {
    BOOL ducking = _fadeSelector == @selector(_finishDucking:);
    
    [_fadeTimer invalidate];
    _fadeTimer = [NSTimer scheduledTimerWithTimeInterval:_fadeInterval
                                                  target:self 
                                                selector:_fadeSelector
                                                userInfo:ducking ? nil : [NSNumber numberWithFloat:_fadeStep] 
                                                 repeats:!ducking];
}


#pragma mark -
#pragma Ducking
- (void)duckOverInterval:(NSTimeInterval)interval {
    if (!_player.isPlaying || _player == nil) return;
    
    _player.volume = _volume*_duckPercentage;
    
    _duckStartTime = CFAbsoluteTimeGetCurrent();
    _fadeInterval = interval;
    _fadeSelector = @selector(_finishDucking:);
    
    [self startFadeTimer];
}


- (void)_finishDucking:(NSTimer*)timer {
    _fadeSelector = NULL;
	_fadeTimer = nil;
    [self fadeUp];
}

#pragma mark -
#pragma AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (self.delegate && [self.delegate respondsToSelector:@selector(ambientTrackDidFinishPlaying:)])
		[self.delegate ambientTrackDidFinishPlaying:self];
}
@end
