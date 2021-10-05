//
//  SPSound.m
//  Frenzy
//
//  Created by Jonathan on 8/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SPSound.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SPAudio.h"

static ALenum 
GetALFormat(AudioStreamBasicDescription inFileFormat)
{
	if (inFileFormat.mFormatID != kAudioFormatLinearPCM)
		return AL_INVALID_VALUE;
	
	if ((inFileFormat.mChannelsPerFrame > 2) || (inFileFormat.mChannelsPerFrame < 1))
		return AL_INVALID_VALUE;
	
	if(inFileFormat.mBitsPerChannel == 8)
		return (inFileFormat.mChannelsPerFrame == 1) ? AL_FORMAT_MONO8 : AL_FORMAT_STEREO8;
	else if(inFileFormat.mBitsPerChannel == 16)
		return (inFileFormat.mChannelsPerFrame == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
	
	return AL_INVALID_VALUE;
}

@implementation SPSound

- (id)initWithContentOfFile:(NSString*)filePath {
	if ((self = [super init])) {
		// make sure OpenAL has been initialized
		ALCcontext *context = alcGetCurrentContext();
        if (context == NULL) {
            return nil;
        }
        
        alGetError(); // clear the error queue
		
		AudioFileID fileID;
		AudioStreamBasicDescription format;
		UInt64 fileSize = 0;
		UInt32 dataSize;
		void *data;
		
		// create a url object to open
		CFURLRef theURL = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (UInt8*)[filePath UTF8String], [filePath length], false);
		if (theURL == NULL) {
			NSLog(@"Could not create audio file URL for path: %@", filePath);
			return nil;
		}
		
		// open the url object
		OSStatus result = AudioFileOpenURL(theURL, kAudioFileReadPermission, 0, &fileID);

		if (result != noErr) {
            CFRelease(theURL);
			NSLog(@"Error opening audio file \"%@\"", [filePath lastPathComponent]);
			return nil;
		}
		
		CFRelease(theURL);
		
		// get the format of the audio file
		UInt32 thePropSize = sizeof(format);				
		result = AudioFileGetProperty(fileID, kAudioFilePropertyDataFormat, &thePropSize, &format);
		if (result != noErr) {
			NSLog(@"Error getting format of audio file %@", [filePath lastPathComponent]);
			return nil;
		}
		
		// get the data size of the audio file
		thePropSize = sizeof(UInt64);
		result = AudioFileGetProperty(fileID, kAudioFilePropertyAudioDataByteCount, &thePropSize, &fileSize);
		if (result != noErr) {
			NSLog(@"Error getting data size of audio file %@", [filePath lastPathComponent]);
			return nil;
		}
		
		// make sure it is the right format
		if (!TestAudioFormatNativeEndian(format) && (format.mBitsPerChannel > 8)) {
			NSLog(@"Invalid format for audio file %@", [filePath lastPathComponent]);
			return nil;
		}
		
		// make room for the audio data
		dataSize = (UInt32)fileSize;
		data = malloc(dataSize);
		
		// read the audio file
		result = AudioFileReadBytes(fileID, false, 0, &dataSize, data);
		if (result != noErr) {
			NSLog(@"Error reading data from audio file %@", [filePath lastPathComponent]);
			if (data) free(data);
			return nil;
		}
		
		// create a buffer
		alGenBuffers(1, &_buffer);
        
        ALenum error = alGetError();
		if (error != AL_NO_ERROR)
		{
			NSLog(@"Error generating OpenAL buffer: 0x%04X", error);
			if (data) free(data);
			return nil;
		}
		
		// add the data to the OpenAL buffer
		alBufferData(_buffer, GetALFormat(format), data, dataSize, format.mSampleRate);
		
		// free the data
		if (data) free(data);
		// close the audio file
		AudioFileClose(fileID);
		
		// check for errors
        error = alGetError();
		if (error != AL_NO_ERROR)
		{
			NSLog(@"Error adding data to OpenAL buffer: %@", filePath);
			
			return nil;
		}
		
		// generate the OpenAL source
		alGenSources(1, &_source);
        error = alGetError();
		if (error != AL_NO_ERROR)
		{
			NSLog(@"Error generating OpenAL source");

			return nil;
		}
		
		alSourcei(_source, AL_BUFFER, _buffer);
        error = alGetError();
		if (error != AL_NO_ERROR)
		{
			NSLog(@"Error attaching buffer to source");
			return nil;
		}
	}
	return self;
}

- (void)dealloc {
    if (_source)
        alDeleteSources(1, &_source);
    if (_buffer)
        alDeleteBuffers(1, &_buffer);
}

+ (SPSound *)soundNamed:(NSString*)fileName {	
	// if not, create a new sound
	NSBundle *bundle = [NSBundle mainBundle];
	SPSound *sound = [[SPSound alloc] initWithContentOfFile:[bundle pathForResource:fileName ofType:nil]];
	
	return sound;
}

- (void)play {
    if ([SPAudio sharedAudio].soundsEnabled)
        alSourcePlay(_source);
}

- (void)pause {
	alSourcePause(_source);
}

- (void)rewind {
	alSourceRewind(_source);
}

- (void)stop {
	alSourceStop(_source);
}

- (ALfloat)gain {
	ALfloat gain;
	alGetSourcef(_source, AL_GAIN, &gain);
	return gain;
}

- (void)setGain:(ALfloat)gain {
	alSourcef(_source, AL_GAIN, gain);
}

- (void)fadeIn {
    if ([SPAudio sharedAudio].soundsEnabled) {
        alSourcef(_source, AL_GAIN, 0.f);
        alSourcePlay(_source);
        [self performSelector:@selector(fadeInStep) withObject:nil afterDelay:0.1];
    }
}

- (void)fadeInStep {
    self.gain += 0.1;
    if (self.gain < 1.f) {
        [self performSelector:@selector(fadeInStep) withObject:nil afterDelay:0.1];
    } else {
        self.gain = 1.f;
    }
}

- (void)fadeOut {
    if (self.state == SPSoundStatePlaying) {
        
        [self performSelector:@selector(fadeOutStep) withObject:nil afterDelay:0.1];
    }
}

- (void)fadeOutStep {
    self.gain -= 0.1;
    if (self.gain > 0.1f) {
        [self performSelector:@selector(fadeOutStep) withObject:nil afterDelay:0.1];
    } else {
        self.gain = 0.f;
        [self stop];
    }
}

- (ALfloat)pitch {
	ALfloat pitch;
	alGetSourcef(_source, AL_PITCH, &pitch);
	return pitch;
}

- (void)setPitch:(ALfloat)pitch {
	alSourcef(_source, AL_PITCH, pitch);
}

- (BOOL)loops {
	ALint loops;
	alGetSourcei(_source, AL_LOOPING, &loops);
	return (loops == AL_TRUE);
}

- (void)setLoops:(BOOL)flag {
	alSourcei(_source, AL_LOOPING, (ALint)flag);
}

- (SPSoundState)state {
	ALint state;
	alGetSourcei(_source, AL_SOURCE_STATE, &state);
	
	switch (state) {
		case AL_PLAYING:
			return SPSoundStatePlaying;
		case AL_PAUSED:
			return SPSoundStatePaused;
		default:
			return SPSoundStateStopped;
	}
	
}

- (void)setPlaybackPosition:(ALfloat)playbackPosition {
    alSourcef(_source, AL_SEC_OFFSET, playbackPosition);
}

- (ALfloat)playbackPosition {
    ALfloat position;
    alGetSourcef(_source, AL_SEC_OFFSET, &position);
    return position;
}
@end
