//
//  SPTexturePack.m
//  Aqueduct Project
//
//  Created by Jonathan on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPTexturePack.h"
#import "SPReadWrite.h"




NSString *kSPTexPackScaleKey = @"SPTexPackScaleKey";
NSString *kSPTexPackFileNameKey = @"SPTexPackNameKey";

/*
@interface SPTexturePack ()
@property (strong, readonly) NSDictionary *fileNames;
@property (strong, readonly) NSMutableDictionary *textures;
@property (strong, readonly) NSString *packPath;
@property (readonly) BOOL retainTextures;
@property (readonly) BOOL encoded;
@end*/


@implementation SPTexturePack

- (id)initWithContentsOfFile:(NSString*)path preload:(BOOL)preload retain:(BOOL)retain {
	if ((self = [super init])) {
		_retainTextures = retain;
		_packPath = path;
		
		if (_retainTextures)
			_textures = [[NSMutableDictionary alloc] initWithCapacity:10];
		
		
		NSMutableDictionary *fileNames = [NSMutableDictionary dictionaryWithCapacity:10];
		
		NSData *data = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"info"]];
        uint32_t fileTag;
        [data getBytes:&fileTag length:sizeof(uint32_t)];
        
        if (fileTag != kSPTexturePackFileTag) {
            // data may be encoded
            data = [NSData dataWithSPData:data];
            [data getBytes:&fileTag length:sizeof(uint32_t)];
            _encoded = YES;
            if (fileTag != kSPTexturePackFileTag) {
                return nil;
            }
        }
        
        uint32_t nTextures;
		[data getBytes:&nTextures range:NSMakeRange(sizeof(uint32_t), sizeof(unsigned int))];
		
		if (!nTextures) {
			return nil;
		}
		
		
		
#if TARGET_OS_IPHONE
        // what device are we running on?
        int wantedFile = kSPTexPackFilePhoneLo;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            wantedFile = [UIScreen mainScreen].scale>=2.0 ? kSPTexPackFilePadHi : kSPTexPackFilePadLo;
        } else {
            wantedFile = [UIScreen mainScreen].scale>=2.0 ? kSPTexPackFilePhoneHi : kSPTexPackFilePhoneLo;
        }
#else
        int wantedFile = kSPTexPackFilePadLo;
#endif
        
        
		// parse info into foundation structure
		const char *bytes, *readBytes;
		bytes = readBytes = (const char*)([data bytes]+sizeof(unsigned int)+sizeof(uint32_t));
		
		
		for (int i=0; i<nTextures; ++i) {
			NSString *name = nil;
			NSDictionary *info = nil;
			
			
			for (int j=0; j<5; ++j) {
				int offset = 0;
				while (*readBytes != '\0') {
					++offset;
					++readBytes;
				}
				
				NSString *file = [NSString stringWithCString:bytes encoding:NSUTF8StringEncoding];
                
				
				if (file.length) {
					if (j == kSPTexPackFileName) {
						name = file;
                        
					} else if (j == wantedFile) {
						float scale = (j==kSPTexPackFilePhoneHi||j==kSPTexPackFilePadHi) ? 2. : 1.;
						info = [NSDictionary dictionaryWithObjectsAndKeys:file, kSPTexPackFileNameKey, [NSNumber numberWithFloat:scale], kSPTexPackScaleKey,  nil];
					}					
				}
				
				bytes += offset+1;
				++readBytes;
			}
			
			if (info)
				[fileNames setObject:info forKey:name];
		}
		
		_fileNames = [fileNames copy];
        
		if (preload) {
			// load all textures;
			for (NSString *name in self.names) {
				NSDictionary *info = [_fileNames objectForKey:name];
				NSString *fileName = [info objectForKey:kSPTexPackFileNameKey];
				SPFloat scale = [[info objectForKey:kSPTexPackScaleKey] floatValue];
                
                NSString *texPath = [path stringByAppendingPathComponent:fileName];
                NSData *texData = _encoded ?[NSData dataWithContentsOfSPFile:texPath] : [NSData dataWithContentsOfFile:texPath];
                SPTexture *tex = [[SPTextureAtlas alloc] initWithAltasData:texData scale:scale options:SPTextureOptionsDefault];
                if (!tex)
                    tex = [[SPTexture alloc] initWithPNGData:texData scale:scale options:SPTextureOptionsDefault];
				
				if (tex != nil && _retainTextures)
					[_textures setObject:tex forKey:name];
			}
		}
	}
	return self;
}

- (void)unloadTextures {
	[_textures removeAllObjects];
}


- (SPTexture*)textureNamed:(NSString*)name {
    
    SPTexture *texture = (_retainTextures) ? [_textures objectForKey:name] : nil;
	
	if (!texture) {
		NSDictionary *info = [_fileNames objectForKey:name];
		NSString *fileName = [info objectForKey:kSPTexPackFileNameKey];
		SPFloat scale = [[info objectForKey:kSPTexPackScaleKey] floatValue];
        
        NSString *texPath = [_packPath stringByAppendingPathComponent:fileName];
        NSData *texData = _encoded ? [NSData dataWithContentsOfSPFile:texPath] : [NSData dataWithContentsOfFile:texPath];
        if (texData) {
            texture = [[SPTextureAtlas alloc] initWithAltasData:texData scale:scale options:SPTextureOptionsDefault];
            
            if (!texture)
                texture = [[SPTexture alloc] initWithPNGData:texData scale:scale options:SPTextureOptionsDefault];
            
            if (_retainTextures && texture!=nil)
                [_textures setObject:texture forKey:name];
        }
		
	}
	
	return texture;
}

- (NSArray*)names {
	return [_fileNames allKeys];
}

- (SPTexture *)loadedTextureWithName:(NSString*)name {
    return [_textures objectForKey:name];
}

#if TARGET_OS_IPHONE
- (void)loadTextureNamed:(NSString*)name completionHandler:(SPLoadTextureCompletionBlock)block {
    SPTexture *tex = (_retainTextures) ? [_textures objectForKey:name] : nil;
    
    if (tex) {
        block(tex);
    } else {

        __block SPTexture * texture = nil;
        NSDictionary *info = [_fileNames objectForKey:name];
        NSString *fileName = [info objectForKey:kSPTexPackFileNameKey];
        __block SPFloat scale = [[info objectForKey:kSPTexPackScaleKey] floatValue];
        __block NSString *texPath = [_packPath stringByAppendingPathComponent:fileName];
        __block BOOL encoded = _encoded;
        
        __block EAGLSharegroup *shareGroup = [EAGLContext currentContext].sharegroup;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

            EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:shareGroup];
            [EAGLContext setCurrentContext:context];

            NSData *texData = encoded ? [NSData dataWithContentsOfSPFile:texPath] : [NSData dataWithContentsOfFile:texPath];
            if (texData) {
                texture = [[SPTextureAtlas alloc] initWithAltasData:texData scale:scale options:SPTextureOptionsDefault];
                
                if (!texture)
                    texture = [[SPTexture alloc] initWithPNGData:texData scale:scale options:SPTextureOptionsDefault];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (_retainTextures && texture)
                    [_textures setObject:texture forKey:name];
                
                block(texture);
            });
            
        });
    }      
}
#endif
@end
