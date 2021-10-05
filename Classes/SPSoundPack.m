//
//  SPSoundPack.m
//  Spell Rift Level Editor
//
//  Created by Jonathan Kieffer on 5/28/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "SPSoundPack.h"

@interface SPSoundPack ()
@property (nonatomic, readonly) BOOL retainSounds;
@end

@implementation SPSoundPack
- (id)initWithContentsOfFile:(NSString*)path preload:(BOOL)preload retain:(BOOL)retain {
    if ((self = [super init])) {
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        BOOL isDir=NO;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            _packPath = path;
            _retainSounds = retain;
            
            if (retain) {
                _sounds = [[NSMutableDictionary alloc] initWithCapacity:10];
            
                if (preload) {
                    NSArray *subpaths = [fm subpathsAtPath:path];
                    if (subpaths.count) {
                        for (NSString *soundFile in subpaths) {
                            NSString *soundPath = [_packPath stringByAppendingPathComponent:soundFile];
                            SPSound *sound = [[SPSound alloc] initWithContentOfFile:soundPath];
                            NSString *name = [soundPath lastPathComponent];
                            if (sound) {
                                [_sounds setObject:sound forKey:name];
                            }
                        }
                        
                    }
                }
            }
        } else {
            return nil;
        }
    }
    return self;
}

@synthesize retainSounds = _retainSounds;

- (SPSound*)soundNamed:(NSString*)name {
    SPSound *sound = _retainSounds ? [_sounds objectForKey:name] : nil;
    if (!sound) {
        NSString *soundPath = [_packPath stringByAppendingPathComponent:name];
        sound = [[SPSound alloc] initWithContentOfFile:soundPath];
        if (sound && _retainSounds) {
            [_sounds setObject:sound forKey:name];
        }
    }
    return sound;
}
@end
