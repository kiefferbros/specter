//
//  SPSoundEngine.h
//  Specter
//
//  Created by Jonathan on 8/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

/* This class uses OpenAL to play short sound effects. More discussion to follow. */

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>


typedef enum {
	SPSoundStatePlaying,
	SPSoundStatePaused,
	SPSoundStateStopped
} SPSoundState;


@interface SPSound : NSObject
{
@private
	ALuint _source, _buffer;
}
@property(nonatomic) ALfloat gain;
@property(nonatomic) ALfloat pitch;
@property(nonatomic) BOOL loops;
@property(readonly) SPSoundState state;
@property(nonatomic) ALfloat playbackPosition;
- (id)initWithContentOfFile:(NSString*)filePath;

// returns a sound object with the fileName from the main app bundle
+ (SPSound *)soundNamed:(NSString*)fileName;

- (void)play;
- (void)pause;
- (void)stop;
- (void)rewind;

- (void)fadeIn;
- (void)fadeOut;

@end

