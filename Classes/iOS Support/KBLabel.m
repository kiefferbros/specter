//
//  KBLabel.m
//  Aqueduct Project
//
//  Created by Jonathan on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "KBLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface _KBFontManager : NSObject
{
	NSMutableDictionary *_fonts;
}
+ (_KBFontManager *)defaultManager;
- (void)cacheFont:(KBFont *)font withName:(NSString*)name;
- (KBFont*)cachedFontWithName:(NSString *)name;
@end

@interface KBLabel () 
- (void)updateText;
@end

@implementation KBLabel
@synthesize width=_width;
@synthesize numberOfLines=_numberOfLines;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		//[self.layer setAffineTransform:CGAffineTransformMakeScale(1., -1.)];
	}
	return self;
}



- (void)setFont:(KBFont*)font {

	_font = font;
	
	_leading = _font.defaultLeading;
	_tracking = _font.defaultTracking;
	[self updateText];
}

- (KBFont*)font {
	return _font;
}

- (void)setText:(NSString*)text {
	_text = text;
	[self updateText];
}

- (NSString*)text  {
	return _text;
}

- (void)setTracking:(SPFloat)aFloat {
	_tracking = aFloat;
	[self updateText];
}

- (SPFloat)tracking {
	return _tracking;
}

- (void)setLeading:(SPFloat)leading {
	_leading = leading;
	[self updateText];
}

- (SPFloat)leading {
	return _leading;
}

- (void)updateText {
	// clear sub layers
	[self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	
	//get the number of non-space characters
	NSUInteger charCount=0;
	for (int i=0; i<[_text length]; ++i) {
		unichar c = [_text characterAtIndex:i];
		if ([_font infoForCharacter:c] != NULL)
			++charCount;
	}
	
	if (charCount) {
		_width = 0.0f;
		_numberOfLines = 1;
		
		SPFloat x=0, y=0;
		for (int i=0; i<[_text length]; ++i) {
			unichar character = [_text characterAtIndex:i];
			
			// tex coords
			SPFloat imgWidth, imgHeight, s;
			imgWidth = CGImageGetWidth(_font.image);
			imgHeight = CGImageGetHeight(_font.image);
			s = _font.scale;
			
			if (character == ' ') {
				x += _font.spaceWidth + _tracking;
			} else if (character == '\n') {
				_width = SPFloatMax(x-_tracking, _width);
				_numberOfLines++;
				
				y -= _leading;
				x = 0;
				
			} else if (character == '\t') {
				x += _font.tabWidth + _tracking;
			} else {
				SPCharInfo *info = [_font infoForCharacter:character];				
				if (info) {
					// create new CALayer
					CALayer *layer = [CALayer layer];
					layer.opaque = NO;
					layer.masksToBounds = YES;
					layer.contents = (id)_font.image;
					CGFloat w, h, th;
					w = info->width/s; h = info->height/s;
					layer.frame = CGRectMake(x+info->frontPad, (y-info->offsetY) - h, w, h);
					th = info->height/imgHeight;
					layer.contentsRect = CGRectMake(info->x/imgWidth, (imgHeight-info->y)/imgHeight-th, info->width/imgWidth, th);
					[self.layer addSublayer:layer];
		
					x += w+info->frontPad+info->backPad+_tracking;
				} else {
					x += _font.spaceWidth + _tracking;
				}
			}			
		}
		_width = SPFloatMax(x-_tracking, _width);
	} else {
		_numberOfLines = 0;
		_width = 0.0f;
	}
	
	[self setNeedsDisplay];
}

@end




@implementation KBFont 

@synthesize image=_image;
@synthesize spaceWidth = _spaceWidth;
@synthesize tabWidth = _tabWidth;
@synthesize defaultTracking = _tracking;
@synthesize defaultLeading = _leading;
@synthesize scale = _scale;

+ (KBFont*)fontNamed:(NSString *)name {
	if (![[name pathExtension] length])
		name = [name stringByAppendingPathExtension:@"spfont"];
	
	KBFont *font = [[_KBFontManager defaultManager] cachedFontWithName:[SPTexture hiResNameForName:name]];
	if (!font) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *path = [bundle pathForResource:name ofType:nil];
		SPFloat ss, ts;
		path = [SPTexture hiResPathForPath:path screenScale:&ss textureScale:&ts];
		
		
		font = [[KBFont alloc] initWithContentsOfFile:path];
		[[_KBFontManager defaultManager] cacheFont:font withName:[path lastPathComponent]];
	}
	
	return font;	
}

- (id)initWithContentsOfFile:(NSString*)filePath {
	SPFloat ss, ts;
	filePath = [SPTexture hiResPathForPath:filePath screenScale:&ss textureScale:&ts];
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [self initWithData:data];
}

- (id)initWithData:(NSData*)data {
	if ((self=[super init])) {
		// read the header
		SPFontHeader header;
		
		NSRange readRange = NSMakeRange(0, sizeof(header));
		
		[data getBytes:&header range:readRange];
		readRange.location += readRange.length;
		
		// update instance variables
		_spaceWidth = header.spaceWidth;
		_tabWidth = header.tabWidth;
		_tracking = header.tracking;
		_leading = header.leading;
		_scale = header.scale;
		_numberOfCharacters = header.nCharacters;
		
		// create character info
		readRange.length = sizeof(SPCharInfo)*_numberOfCharacters;
		_charInfo = (SPCharInfo*)malloc(readRange.length);
		
		[data getBytes:_charInfo range:readRange];
		readRange.location += readRange.length;
		readRange.length = header.textureDataLength;
		
		NSData *texData = [data subdataWithRange:readRange];
		
		CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)texData);
		_image = CGImageCreateWithPNGDataProvider(provider, NULL, FALSE, kCGRenderingIntentDefault);
		CGDataProviderRelease(provider);
		
		
		/*
		CGSize size = CGSizeMake(header.textureWidth, header.textureHeight);
		
		
		// create cg image from texture data
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate((void*)([data bytes]+readRange.location), size.width, size.height, 8, 4*header.textureWidth, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
	
		CGColorSpaceRelease(colorSpace);
		
		_image = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		*/
		
	}
	return self;
}

- (void)dealloc {
	free(_charInfo);
	CGImageRelease(_image);
}


- (SPCharInfo *)charInfo {
	return _charInfo;
}

- (SPCharInfo *)infoForCharacter:(unichar)character {
	for (int i=0; i<_numberOfCharacters; ++i) {
		if (_charInfo[i].character == character) {
			return &_charInfo[i];
		}
	}
	
	return NULL;
}
@end

static _KBFontManager *_sharedFontManager;

@implementation _KBFontManager
+ (_KBFontManager*)defaultManager {
	if (!_sharedFontManager) 
		_sharedFontManager = [[_KBFontManager alloc] init];
	
	return _sharedFontManager;
}

- (id)init {
	if ((self=[super init])) {
		_fonts = [[NSMutableDictionary alloc] initWithCapacity:5];
		
#if TARGET_OS_IPHONE
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(handleMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
	}
	return self;
}

// release any fonts that are not retained by any other object
/*
- (void)handleMemoryWarning:(NSNotification*)note {
	NSArray *keys = [_fonts allKeys];
	
	for (NSString *key in keys) {
		KBFont *font = [_fonts objectForKey:key];
		if ([font retainCount] == 1) {
			[_fonts removeObjectForKey:key];
		}
	}
}
*/

- (void)cacheFont:(KBFont *)font withName:(NSString*)name {
	if (font)
		[_fonts setObject:font forKey:name];
}

- (KBFont*)cachedFontWithName:(NSString *)name {
	return [_fonts objectForKey:name];
}

@end