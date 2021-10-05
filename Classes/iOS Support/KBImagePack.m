//
//  KBImagePack.m
//  MonsterSoup
//
//  Created by Jonathan Kieffer on 2/25/11.
//  Copyright 2011 Kieffer Bros., LLC. All rights reserved.
//

#import "KBImagePack.h"

@interface KBImagePack ()
- (UIImage*)imageWithContentsOfFile:(NSString*)path scale:(SPFloat)scale;
@end



@implementation KBImagePack

- (id)initWithContentsOfFile:(NSString*)path preload:(BOOL)preload retain:(BOOL)retain {
	if ((self = [super init])) {
		_retainImages = retain;
		_packPath = path;
		
		if (_retainImages)
			_images = [[NSMutableDictionary alloc] initWithCapacity:10];
		
		
		NSMutableDictionary *fileNames = [NSMutableDictionary dictionaryWithCapacity:10];
		
		NSData *data = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"info"]];
		
		[data getBytes:&_nImages length:sizeof(unsigned int)];
		
		if (!_nImages) {
			return nil;
		}
		
		// parse info into foundation structure
		int wantedFile = kSPTexPackFileLoRes;
#if TARGET_OS_IPHONE
		UIDevice* device = [UIDevice currentDevice];
		if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
			wantedFile = kSPTexPackFilePad;
		
		UIScreen *screen = [UIScreen mainScreen];	
		if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
			wantedFile = kSPTexPackFileHiRes;
#endif
		
		const char *bytes, *readBytes;
		bytes = readBytes = (const char*)([data bytes]+sizeof(unsigned int));
		
		
		for (int i=0; i<_nImages; ++i) {
			NSString *name = nil;
			NSDictionary *info = nil;
			
			
			for (int j=0; j<4; ++j) {
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
						float scale = (j == kSPTexPackFileHiRes) ? 2. : 1.;						
						
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
		
		
		if (preload && retain) {
			// load all textures;
			for (NSString *name in self.names) {
				NSDictionary *info = [_fileNames objectForKey:name];
				NSString *fileName = [info objectForKey:kSPTexPackFileNameKey];
				SPFloat scale = [[info objectForKey:kSPTexPackScaleKey] floatValue];
				UIImage *image = [self imageWithContentsOfFile:[path stringByAppendingPathComponent:fileName] scale:scale];
				
				if (_retainImages)
					[_images setObject:image forKey:name];

			}
		}
	}
	return self;
}


- (UIImage*)imageWithContentsOfFile:(NSString*)path scale:(SPFloat)scale {
	CGDataProviderRef provider = CGDataProviderCreateWithFilename([path UTF8String]);
	CGImageRef cgImage = NULL;
	
	cgImage = CGImageCreateWithPNGDataProvider(provider, NULL, FALSE, kCGRenderingIntentDefault);
	CGDataProviderRelease(provider);
	
	UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(cgImage);
	
	return image;
}

- (void)unloadImages {	
	[_images removeAllObjects];
}


// release any textures that are not retained by any other object
- (UIImage*)imageNamed:(NSString*)name {
	
	UIImage *image = [_images objectForKey:name];
	
	if (!image) {
		NSDictionary *info = [_fileNames objectForKey:name];
		NSString *fileName = [info objectForKey:kSPTexPackFileNameKey];
		SPFloat scale = [[info objectForKey:kSPTexPackScaleKey] floatValue];
		
		image = [self imageWithContentsOfFile:[_packPath stringByAppendingPathComponent:fileName] scale:scale];
		
		if (_retainImages)
			[_images setObject:image forKey:name];
		
	}
	
	return image;
}

- (NSArray*)names {
	return [_fileNames allKeys];
}
@end
