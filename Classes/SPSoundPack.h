//
//  SPSoundPack.h
//  Spell Rift Level Editor
//
//  Created by Jonathan Kieffer on 5/28/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSound.h"

@interface SPSoundPack : NSObject {
    NSMutableDictionary *_sounds;
    NSString *_packPath;
}
- (id)initWithContentsOfFile:(NSString*)path preload:(BOOL)preload retain:(BOOL)retain;
- (SPSound*)soundNamed:(NSString*)name;
@end
