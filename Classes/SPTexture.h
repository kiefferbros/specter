//
//  SPTexture.h
//  Orba
//
//  Created by Jonathan on 9/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGeometry.h"

#if TARGET_OS_IPHONE
	#import <OpenGLES/ES1/gl.h>
#else
	#import <OpenGL/OpenGL.h>
#endif

typedef enum {
	SPTexturePixelFormatRGBA = 0,
    SPTexturePixelFormatRGBA4,
	SPTexturePixelFormatAlpha,
    SPTexturePixelFormatLuminanceAlpha,
	SPTexturePixelFormatPVRTC2 = 24,
	SPTexturePixelFormatPVRTC4
} SPTexturePixelFormat;

enum {
    SPTextureOptionsDefault = 0x00,  // clamp s to edge, clamp t to edge, min filter linear, mag filter linear, no mipmap generation
    SPTextureOptionRepeatS = 0x01,
    SPTextureOptionRepeatT = 0x02,
    SPTextureOptionMinFilterNearest = 0x04,
    SPTextureOptionMagFilterNearest = 0x08,
    SPTextureOptionGenerateMipmap = 0x016
};
typedef unsigned char SPTextureOptions;

@interface SPTexture : NSObject {
@package
	GLuint		_glName;
	GLuint		_glWidth, _glHeight;
	GLfloat		_maxS, _maxT;
	
	SPVec2		_size;
	SPFloat		_scale;
	
	BOOL		_usesMipMaps;
}

@property (readonly, nonatomic) GLuint glName;
@property (readonly, nonatomic) GLuint glWidth, glHeight;
@property (readonly, nonatomic) GLfloat maxS, maxT;
@property (readonly, nonatomic) SPVec2 contentSize; // in points
@property (assign, nonatomic) SPFloat scale;

// init
/* supports png, jpeg, and opengles native pvr */
+ (id)textureNamed:(NSString*)name;					// caches texture
+ (id)textureNamed:(NSString*)name packName:(NSString*)packName;    // load a single texture from a texture pack (texture will be cached)
- (id)initWithContentsOfFile:(NSString*)filePath;
- (id)initWithContentsOfFile:(NSString*)filePath options:(SPTextureOptions)options;


+ (NSString*)hiResPathForPath:(NSString*)path screenScale:(SPFloat*)screenScale textureScale:(SPFloat*)texScale;
+ (NSString*)hiResNameForName:(NSString*)name;


+ (NSData*)textureDataWithImage:(CGImageRef)image 
                    pixelFormat:(out SPTexturePixelFormat*)format 
                     pixelsWide:(out GLuint*)width 
                     pixelsHigh:(out GLuint*)height 
                    contentSize:(out SPVec2*)size;

- (id)initImageTextureWithContentsOfFile:(NSString*)filePath scale:(SPFloat)texScale options:(SPTextureOptions)options;
- (id)initWithPNGData:(NSData*)spData scale:(SPFloat)texScale options:(SPTextureOptions)options;
- (id)initPVRTextureWithContentsOfFile:(NSString*)filePath scale:(SPFloat)texScale options:(SPTextureOptions)options;
- (id)initWithImage:(CGImageRef)image scale:(SPFloat)texScale options:(SPTextureOptions)options;;

- (id)initWithData:(NSArray*)data 
       pixelFormat:(SPTexturePixelFormat)pixelFormat 
        pixelsWide:(GLuint)width 
        pixelsHigh:(GLuint)height 
       contentSize:(SPVec2)size 
             scale:(SPFloat)texScale
           options:(SPTextureOptions)options;

// draw
- (void)drawAtCenter:(SPVec2)center;
- (void)drawAtOrigin:(SPVec2)origin;
- (void)drawInBox:(SPBox)box;

- (void)drawAtCenter:(SPVec2)center region:(SPBox)drawRegion;
- (void)drawAtOrigin:(SPVec2)origin region:(SPBox)drawRegion;

- (void)drawToScreen:(SPVec2)point;

// use for drawing
- (void)bind;

- (void)setRepeatS:(BOOL)repeats;
- (void)setRepeatT:(BOOL)repeats;
- (void)setMinSmoothing:(BOOL)flag;
- (void)setMagSmoothing:(BOOL)flag;

@end