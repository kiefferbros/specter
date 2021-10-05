//
//  SPTexture.m
//  Orba
//
//  Created by Jonathan on 9/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPTexture.h"
#import "SPTexturePack.h"

#if TARGET_OS_IPHONE
	#import <OpenGLES/ES1/glext.h>
	#import <UIKit/UIKit.h>
#else
	#import <OpenGL/OpenGL.h>
#endif

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

#define k16Bit 0

static char gPVRTexIdentifier[4] = "PVR!";

typedef struct _PVRTexHeader
{
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;

@implementation SPTexture

@synthesize glName = _glName;
@synthesize glWidth = _glWidth, glHeight = _glHeight;
@synthesize maxS = _maxS, maxT = _maxT;
@synthesize contentSize = _size;
@synthesize scale = _scale;

#pragma mark -
#pragma mark Class
+ (NSString*)hiResPathForPath:(NSString*)path screenScale:(SPFloat*)screenScale textureScale:(SPFloat*)texScale {
#if TARGET_OS_IPHONE
	UIScreen *screen = [UIScreen mainScreen];	
	if ([screen respondsToSelector:@selector(scale)])
		*screenScale = screen.scale;
	
	if (*screenScale == 2.f) {
		NSRange searchRange = [path rangeOfString:@"@2x"];
		if (searchRange.location == NSNotFound) {
			// search for 2x file
			NSString *newPath = [path stringByDeletingPathExtension];
			newPath = [newPath stringByAppendingString:@"@2x"];
			newPath = [newPath stringByAppendingPathExtension:[path pathExtension]];
			
			NSFileManager *fm = [NSFileManager defaultManager];
			if ([fm fileExistsAtPath:newPath]) {
				// 2x file exists
				*texScale = 2.f;
				path = newPath;
			}
		} else {
			*texScale = 2.f;
		}
	}
#endif
	
	return path;
}

+ (NSString*)hiResNameForName:(NSString*)name {
#if TARGET_OS_IPHONE
	UIScreen *screen = [UIScreen mainScreen];	
	CGFloat s = 1.f;
	if ([screen respondsToSelector:@selector(scale)])
		s = screen.scale;
	
	if (s == 2.f) {
		NSRange searchRange = [name rangeOfString:@"@2x"];
		if (searchRange.location == NSNotFound) {
			NSString *newName = [name stringByDeletingPathExtension];
			newName = [newName stringByAppendingString:@"@2x"];
			newName = [newName stringByAppendingPathExtension:[name pathExtension]];
			
			name = newName;
		}
	}
#endif
	
	return name;
}

+ (NSData*)textureDataWithImage:(CGImageRef)image pixelFormat:(SPTexturePixelFormat*)outFormat pixelsWide:(out GLuint*)outWidth pixelsHigh:(out GLuint*)outHeight contentSize:(out SPVec2*)outSize {
	NSUInteger				width, height, i, length;
	CGContextRef			context = NULL;
	void*					data = NULL;
	CGColorSpaceRef			colorSpace;
	//BOOL					hasAlpha;
	//CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	SPVec2					imageSize;
	SPTexturePixelFormat    pixelFormat;
	
	
	if(image == NULL) {
		NSLog(@"Image is Null");
		return nil;
	}
	
	
	/*info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || 
				(info == kCGImageAlphaPremultipliedFirst) || 
				(info == kCGImageAlphaLast) || 
				(info == kCGImageAlphaFirst) ? YES : NO);*/
	if(CGImageGetColorSpace(image)) { 
        pixelFormat = SPTexturePixelFormatRGBA;
	} else  //NOTE: No colorspace means a mask image
		pixelFormat = SPTexturePixelFormatAlpha;
	
	
	imageSize = SPVec2Make(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
	
	width = imageSize.x;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
			i *= 2;
		width = i;
	}
	height = imageSize.y;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
			i *= 2;
		height = i;
	}
	
#if TARGET_OS_IPHONE
	GLfixed maxSize;
	glGetFixedv(GL_MAX_TEXTURE_SIZE, &maxSize);
#else
	GLint maxSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxSize);
#endif
	
	while((width > maxSize) || (height > maxSize)) {
		width /= 2;
		height /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.x *= 0.5;
		imageSize.y *= 0.5;
	}
    
    if (width==0 || height==0) {
        return nil;
    }
	
    
	switch(pixelFormat) {		
		case SPTexturePixelFormatRGBA:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			length = height * width * 4;
			data = malloc(length);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;	
		case SPTexturePixelFormatAlpha:
			length = height * width;
			data = malloc(length);
			context = CGBitmapContextCreate(data, width, height, 8, width, NULL, (CGBitmapInfo)kCGImageAlphaOnly);
			break;				
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGContextRelease(context);
    
#if k16Bit
    // reformat into unsigned short 4444
    pixelFormat = SPTexturePixelFormatRGBA4;
    length = height*width*2;
    
    //Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
    void *tempData = malloc(length);
    unsigned int *inPixel32 = (unsigned int*)data;
    unsigned short *outPixel16 = (unsigned short*)tempData;
    for(i = 0; i < width * height; ++i, ++inPixel32)
        *outPixel16++ = 
        ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
        ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | // G
        ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
        ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0); // A
    
    
    free(data);
    data = tempData;
#endif
    
	NSData *imageData = [NSData dataWithBytesNoCopy:data length:length freeWhenDone:YES];

	
	*outFormat = pixelFormat;
	*outWidth = (GLuint)width;
	*outHeight = (GLuint)height;
	*outSize = imageSize;
	
	return imageData;
}

+ (id)textureNamed:(NSString*)name {
	
	
	//SPTexture *texture = [[_SPTextureManager defaultManager] cachedTextureWithName:[SPTexture hiResNameForName:name]];
	//if (!texture) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *path = [bundle pathForResource:name ofType:nil];
		SPFloat ss, ts;
		path = [SPTexture hiResPathForPath:path screenScale:&ss textureScale:&ts];
		
		SPTexture *texture = [[[self class] alloc] initWithContentsOfFile:path];
        //texture = [[[self class] alloc] initWithContentsOfFile:path];
		//[[_SPTextureManager defaultManager] cacheTexture:texture withName:[path lastPathComponent]];
	//}
		
	return texture;
}

+ (id)textureNamed:(NSString*)name packName:(NSString*)packName {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *packPath = [bundle pathForResource:packName ofType:nil];
    
    SPTexturePack *pack = [[SPTexturePack alloc] initWithContentsOfFile:packPath preload:NO retain:NO];
    SPTexture *tex = [pack textureNamed:name];
    
    return tex;
}

#pragma mark -
#pragma mark Initialize
- (id)initWithContentsOfFile:(NSString*)filePath {
    self = [self initWithContentsOfFile:filePath options:SPTextureOptionsDefault];
    return self;
}

- (id)initWithContentsOfFile:(NSString*)filePath options:(SPTextureOptions)options {
	SPFloat screenScale = 1.f, texScale = 1.f;

	filePath = [SPTexture hiResPathForPath:filePath screenScale:&screenScale textureScale:&texScale];
    
    NSString *ext = [[filePath pathExtension] lowercaseString];
	if ([ext isEqualToString:@"pvr"]) {
		return [self initPVRTextureWithContentsOfFile:filePath scale:texScale options:SPTextureOptionsDefault];
	}
    self = [self initImageTextureWithContentsOfFile:filePath scale:texScale options:options];
    return self;
}
			
- (id)initImageTextureWithContentsOfFile:(NSString*)filePath scale:(SPFloat)texScale options:(SPTextureOptions)options {
	CGDataProviderRef provider = CGDataProviderCreateWithFilename([filePath UTF8String]);
	CGImageRef image = NULL;

    NSString *ext = [[filePath pathExtension] lowercaseString];
    if ([ext isEqualToString:@"png"] || [ext isEqualToString:@""]) {
		image = CGImageCreateWithPNGDataProvider(provider, NULL, FALSE, kCGRenderingIntentDefault);
	} else if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) {
        image = CGImageCreateWithJPEGDataProvider(provider, NULL, FALSE, kCGRenderingIntentDefault);
    }
	
	CGDataProviderRelease(provider);

	if (image == NULL) {
		return nil;
	}

	self = [self initWithImage:image scale:texScale options:options];
	CGImageRelease(image);
	
	return self;
}

- (id)initWithPNGData:(NSData*)data scale:(SPFloat)texScale options:(SPTextureOptions)options {

	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
	CGImageRef image = CGImageCreateWithPNGDataProvider(provider, NULL, FALSE, kCGRenderingIntentDefault);

	CGDataProviderRelease(provider);
    
	if (image == NULL) {
		return nil;
	}
    
	self = [self initWithImage:image scale:texScale options:options];
	CGImageRelease(image);
	
	return self;
}

- (id)initWithImage:(CGImageRef)image scale:(SPFloat)texScale options:(SPTextureOptions)options {
	SPTexturePixelFormat	pixelFormat;
	GLuint					width, height;
	SPVec2					imageSize;
	
	NSData *data = [SPTexture textureDataWithImage:image 
									   pixelFormat:&pixelFormat 
										pixelsWide:&width 
										pixelsHigh:&height 
									   contentSize:&imageSize];
	
	NSArray *imageData = [NSArray arrayWithObject:data];

    self =[self initWithData:imageData 
                 pixelFormat:pixelFormat 
                  pixelsWide:width 
                  pixelsHigh:height 
                 contentSize:imageSize 
                       scale:texScale
                     options:options];
	return self;
}

				
- (id)initPVRTextureWithContentsOfFile:(NSString *)filePath scale:(SPFloat)texScale options:(SPTextureOptions)options {
	BOOL success = FALSE;
	PVRTexHeader *header = NULL;
	uint32_t flags, pvrTag;
	uint32_t dataLength = 0, dataOffset = 0, dataSize = 0;
	uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
	uint32_t width = 0, height = 0, bpp = 4, pixelsWide, pixelsHigh;
	uint8_t *bytes = NULL;
	uint32_t formatFlags;
	NSMutableArray *imageData;
	NSData *data;
    
    data = [NSData dataWithContentsOfFile:filePath];
	header = (PVRTexHeader *)[data bytes];
	
	pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
	
	if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
	{
		return nil;
	}
	
	flags = CFSwapInt32LittleToHost(header->flags);
	formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	
	if (formatFlags == SPTexturePixelFormatPVRTC2 || formatFlags == SPTexturePixelFormatPVRTC4)
	{
		imageData = [NSMutableArray arrayWithCapacity:10];
		
		pixelsWide = width = CFSwapInt32LittleToHost(header->width);
		pixelsHigh = height = CFSwapInt32LittleToHost(header->height);
		
		//if (CFSwapInt32LittleToHost(header->bitmaskAlpha))
		//	_hasAlpha = TRUE;
		//else
		//	_hasAlpha = FALSE;
		
		dataLength = CFSwapInt32LittleToHost(header->dataLength);
		
		bytes = ((uint8_t *)[data bytes]) + sizeof(PVRTexHeader);
		
		// Calculate the data size for each texture level and respect the minimum number of blocks
		while (dataOffset < dataLength)
		{
			if (formatFlags == SPTexturePixelFormatPVRTC4)
			{
				blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
				widthBlocks = width / 4;
				heightBlocks = height / 4;
				bpp = 4;
			}
			else
			{
				blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
				widthBlocks = width / 8;
				heightBlocks = height / 4;
				bpp = 2;
			}
			
			// Clamp to minimum number of blocks
			if (widthBlocks < 2)
				widthBlocks = 2;
			if (heightBlocks < 2)
				heightBlocks = 2;
			
			dataSize = widthBlocks * heightBlocks * ((blockSize  * bpp) / 8);
			
			[imageData addObject:[NSData dataWithBytes:bytes+dataOffset length:dataSize]];
			
			dataOffset += dataSize;
			
			width = MAX(width >> 1, 1);
			height = MAX(height >> 1, 1);
		}
		
		success = TRUE;
	}
	
	if (!success) {
		return nil;
	}
	self = [self initWithData:imageData 
				  pixelFormat:formatFlags
				   pixelsWide:pixelsWide
				   pixelsHigh:pixelsHigh 
				  contentSize:SPVec2Make(pixelsWide, pixelsHigh) 
						scale:texScale
                      options:options];
    return self;
}

- (id)initWithData:(NSArray*)data
	   pixelFormat:(SPTexturePixelFormat)pixelFormat 
		pixelsWide:(GLuint)pixelsWide 
		pixelsHigh:(GLuint)pixelsHigh 
	   contentSize:(SPVec2)size 
			 scale:(SPFloat)texScale 
           options:(SPTextureOptions)options
{
	GLuint					width, height;
	GLenum					err;
	NSData					*levelData;

	
	if((self = [super init])) {
        glGetError();
		glGenTextures(1, &_glName);
		glBindTexture(GL_TEXTURE_2D, _glName);

		if ([data count] > 1 || (options&SPTextureOptionGenerateMipmap)!=0) {
			_usesMipMaps = YES;
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (options&SPTextureOptionMinFilterNearest)!=0 ? GL_NEAREST_MIPMAP_NEAREST : GL_LINEAR_MIPMAP_LINEAR);
		} else {
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (options&SPTextureOptionMinFilterNearest)!=0 ? GL_NEAREST : GL_LINEAR);
		}
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (options&SPTextureOptionMinFilterNearest)!=0 ? GL_NEAREST : GL_LINEAR);
		
        
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (options&SPTextureOptionRepeatS)!=0 ? GL_REPEAT : GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (options&SPTextureOptionRepeatT)!=0 ? GL_REPEAT : GL_CLAMP_TO_EDGE);
        
#if TARGET_OS_IPHONE
		GLint cropRect[4] = { 0, 0, size.x, size.y };
		glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_CROP_RECT_OES, cropRect);
#endif
		
		width = pixelsWide;
		height = pixelsHigh;
		
		for (int i=0; i<[data count]; ++i) {
			levelData = [data objectAtIndex:i];
            

			switch(pixelFormat) {
				case SPTexturePixelFormatRGBA:
					glTexImage2D(GL_TEXTURE_2D, i, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [levelData bytes]);
					break;
                case SPTexturePixelFormatRGBA4:
					glTexImage2D(GL_TEXTURE_2D, i, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, [levelData bytes]);
					break;
				case SPTexturePixelFormatAlpha:
					glTexImage2D(GL_TEXTURE_2D, i, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, [levelData bytes]);
					break;
                case SPTexturePixelFormatLuminanceAlpha:
					glTexImage2D(GL_TEXTURE_2D, i, GL_LUMINANCE_ALPHA, width, height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, [levelData bytes]);
					break;
#if TARGET_OS_IPHONE
				case SPTexturePixelFormatPVRTC2:
					glCompressedTexImage2D(GL_TEXTURE_2D, i, GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, width, height, 0, (GLsizei)[levelData length], (GLvoid *)[levelData bytes]);
					break;
				case SPTexturePixelFormatPVRTC4:
					glCompressedTexImage2D(GL_TEXTURE_2D, i, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, width, height, 0, (GLsizei)[levelData length], (GLvoid *)[levelData bytes]);
					break;
#endif
				default:
					[NSException raise:NSInternalInconsistencyException format:@""];
			}
			
			err = glGetError();
			if (err != GL_NO_ERROR)
			{
				NSLog(@"Error uploading texture level: %d. glError: 0x%04X", i, err);
				return nil;
			}
			
			width = MAX(width >> 1, 1);
			height = MAX(height >> 1, 1);
		}
        
        if ([data count] == 1 && (options&SPTextureOptionGenerateMipmap)!=0) {
#if TARGET_OS_IPHONE
            glGenerateMipmapOES(GL_TEXTURE_2D);
#else
            glGenerateMipmap(GL_TEXTURE_2D);
#endif
        }
		
		_size = size;
		_glWidth = pixelsWide;
		_glHeight = pixelsHigh;
		_maxS = size.x / (float)pixelsWide;
		_maxT = size.y / (float)pixelsHigh;
		_scale = texScale;
		
		_size.x /= texScale;
		_size.y /= texScale;
		
		
	}					
	return self;
}

- (void)dealloc {
	if (_glName) glDeleteTextures(1, &_glName);
}

// doesn't create new texture, just copies meta data
- (id)copyWithZone:(NSZone *)zone {
	SPTexture *copy = [[[self class] allocWithZone:zone] init];
	
	copy->_glName = _glName;
	copy->_glWidth = _glWidth;
	copy->_glHeight = _glHeight;
	copy->_maxS = _maxS;
	copy->_maxT = _maxT;
	copy->_size = _size;
	copy->_scale = _scale;
	copy->_usesMipMaps = _usesMipMaps;
	
	return copy;
}

- (void)setRepeatS:(BOOL)repeats {
	GLint saveName;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	
	glBindTexture(GL_TEXTURE_2D, _glName);
	
	if (repeats) {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	} else {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	}
	
	glBindTexture(GL_TEXTURE_2D, saveName);
}

- (void)setRepeatT:(BOOL)repeats {
	GLint saveName;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	
	glBindTexture(GL_TEXTURE_2D, _glName);
	
	if (repeats) {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	} else {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}
	
	glBindTexture(GL_TEXTURE_2D, saveName);
}

- (void)setMinSmoothing:(BOOL)flag {
    GLint saveName;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	
	glBindTexture(GL_TEXTURE_2D, _glName);
	
	if (_usesMipMaps)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, flag ? GL_LINEAR_MIPMAP_LINEAR : GL_NEAREST_MIPMAP_NEAREST);
	else 
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, flag ?  GL_LINEAR : GL_NEAREST);

	glBindTexture(GL_TEXTURE_2D, saveName);
}

- (void)setMagSmoothing:(BOOL)flag {
    GLint saveName;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	glBindTexture(GL_TEXTURE_2D, _glName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, flag ?  GL_LINEAR : GL_NEAREST);
	glBindTexture(GL_TEXTURE_2D, saveName);
}

- (void)setScale:(SPFloat)aScale {
	_size.x*=_scale;
	_size.y*=_scale;
	
	_scale = aScale;
	
	_size.x/=_scale;
	_size.y/=_scale;
}

#pragma mark -
#pragma mark Drawing
- (void)drawAtCenter:(SPVec2)center {
	[self drawAtOrigin:SPVec2Sub(center, SPVec2Scale(SPVec2Make(_size.x, _size.y), 0.5f))];
}

- (void)drawAtOrigin:(SPVec2)origin {
	
	SPVertex vertices[] =  {
		origin.x,				origin.y,			0.f,		0.f,				
		origin.x,				_size.y + origin.y,	0.f,		_maxT,
		_size.x + origin.x,		origin.y,			_maxS,		0.f,
		_size.x + origin.x,		_size.y + origin.y,	_maxS,		_maxT 
	};
	
	glBindTexture(GL_TEXTURE_2D, _glName);
	glVertexPointer(2, GL_FLOAT, sizeof(SPVertex), vertices);
	glTexCoordPointer(2, GL_FLOAT, sizeof(SPVertex), (GLvoid*)vertices+sizeof(GLfloat)*2);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
}

- (void)drawAtCenter:(SPVec2)center region:(SPBox)drawRegion  {
	SPVec2 size = SPVec2Make(SPBoxWidth(drawRegion)/2.f, SPBoxHeight(drawRegion)/2.f);
	[self drawAtOrigin:SPVec2Sub(center, size) region:drawRegion];
}

- (void)drawAtOrigin:(SPVec2)origin region:(SPBox)drawRegion {
	
	SPVec2 size = SPVec2Make(SPBoxWidth(drawRegion), SPBoxHeight(drawRegion));
	SPBox coords = SPBoxMake((drawRegion.l/_size.x)*_maxS, (drawRegion.b/_size.y)*_maxT, (drawRegion.r/_size.x)*_maxS, (drawRegion.t/_size.y)*_maxT);
	
	GLfloat		coordinates[] = { 
		coords.l,		coords.b,
		coords.l,		coords.t,
		coords.r,		coords.b,
		coords.r,		coords.t 
	};
	
	GLfloat		vertices[] = {	
		origin.x,				origin.y,					
		origin.x,				size.y + origin.y,	
		size.x + origin.x,		origin.y,					
		size.x + origin.x,		size.y + origin.y
	};
	
	glBindTexture(GL_TEXTURE_2D, _glName);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)drawInBox:(SPBox)box {
	GLfloat		coordinates[] = { 
		0.f,	0.f,
		0.f,	_maxT,
		_maxS,	0.f,
		_maxS,	_maxT 
	};
	
	GLfloat		vertices[] = {	
		box.l,	box.b,	
		box.l,	box.t,	
		box.r,	box.b,	
		box.r,	box.t
	};
	
	glBindTexture(GL_TEXTURE_2D, _glName);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)drawToScreen:(SPVec2)point {
	glBindTexture(GL_TEXTURE_2D, _glName);
#if TARGET_OS_IPHONE
	glDrawTexfOES(point.x*_scale, point.y*_scale, 0.f, _size.x*_scale, _size.y*_scale);
#endif
}

- (void)bind {
	glBindTexture(GL_TEXTURE_2D, _glName);
}

@end


