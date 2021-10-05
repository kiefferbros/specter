//
//  SPTexturePack.h
//  Aqueduct Project
//
//  Created by Jonathan on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTextureAtlas.h"


typedef void (^SPLoadTextureCompletionBlock)(SPTexture *texture);

static const uint32_t kSPTexturePackFileTag = 'SPTP';

enum {
	kSPTexPackFileName = 0,
	kSPTexPackFilePhoneLo,
	kSPTexPackFilePhoneHi,
	kSPTexPackFilePadLo,
    kSPTexPackFilePadHi
};

extern NSString *kSPTexPackScaleKey;
extern NSString *kSPTexPackFileNameKey;

@interface SPTexturePack : NSObject {
@package
	NSDictionary			*_fileNames;
	
	NSMutableDictionary		*_textures;
	
	NSString				*_packPath;
	
	BOOL					_retainTextures;
    BOOL                    _encoded;
}
@property (nonatomic, readonly) NSArray *names;



- (id)initWithContentsOfFile:(NSString*)path preload:(BOOL)preload retain:(BOOL)retain;

- (SPTexture*)textureNamed:(NSString*)name;
- (void)unloadTextures;

- (SPTexture *)loadedTextureWithName:(NSString*)name;
#if TARGET_OS_IPHONE
- (void)loadTextureNamed:(NSString*)name completionHandler:(SPLoadTextureCompletionBlock)block;
#endif
@end
