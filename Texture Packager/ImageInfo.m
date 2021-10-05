//
//  ImageInfo.m
//  Texture Package Maker
//
//  Created by Jonathan on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageInfo.h"
#import "SPTextureAtlas.h"
#import "SPReadWrite.h"

@implementation ImageInfo
@synthesize name;
@synthesize phoneHiName, phoneLoName, padHiName, padLoName;

- (void)dealloc {
    for (int i=0; i<4; ++i) {
        image[i] = nil;
        atlasData[i] = nil;
    }
}

- (id)initWithName:(NSString*)aPath {
	if ((self = [super init])) {
		name = [[aPath lastPathComponent] stringByDeletingPathExtension];
	}
	return self;
}

- (id)valueForUndefinedKey:(NSString *)key {
	return nil;
}

- (void)loadImage:(InfoImage)imageID atPath:(NSString*)path {
    NSData *data, *imageData;
    
    data = [NSData dataWithContentsOfFile:path];
    SPTextureAtlasHeader *header = (SPTextureAtlasHeader*)[data bytes];
    if (header->atlasTag == kSPTextureAtlasFileTag) {
        NSRange atlasRange = NSMakeRange(0, sizeof(SPTextureAtlasHeader)+sizeof(SPTexAtlasMapCoords)*header->nMaps);
        NSRange pngRange = NSMakeRange(atlasRange.length, header->pngLength);
        
        atlasData[imageID] = [data subdataWithRange:atlasRange];
        imageData = [data subdataWithRange:pngRange];
    } else {
        imageData = data;
    }
    
    image[imageID] = [[NSImage alloc] initWithData:imageData];
    [image[imageID] setName:[path lastPathComponent]];
}

- (NSImage*)image:(InfoImage)imageID {
    return image[imageID];
}

- (NSData*)atlasData:(InfoImage)imageID {
    return atlasData[imageID];
}

- (NSData*)imageData:(InfoImage)imageID {
    NSImage *anImage = image[imageID];
    NSMutableData  *someAtlasData = [atlasData[imageID] mutableCopy];
    
    if (imageID%2==0 && anImage==nil && image[imageID+1]!=nil) {
        // no lo-res version
        NSImage *hiResImage = image[imageID+1];
        NSData *hiResData = atlasData[imageID+1];
        
        // scale down the hi-res image
        NSSize size = NSMakeSize(hiResImage.size.width/2., hiResImage.size.height/2.);
		NSImage *scaledImage = [[NSImage alloc] initWithSize:size];
		
		NSRect rect = NSMakeRect(0, 0, size.width, size.height);
		
		[scaledImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		[hiResImage drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.];
		[scaledImage unlockFocus];
		
		NSBitmapImageRep *rep = [NSBitmapImageRep alloc];
		
		[scaledImage lockFocus];
		rep = [rep initWithFocusedViewRect:rect];
		[scaledImage unlockFocus];
		
		[scaledImage removeRepresentation:[[scaledImage representations] objectAtIndex:0]];
		[scaledImage addRepresentation:rep];
        
        anImage = scaledImage;
        
        if (hiResData) {
            // scale the atlas map coords
            SPTextureAtlasHeader *header = (SPTextureAtlasHeader*)[hiResData bytes];

            
            SPTexAtlasMapCoords *coord = (SPTexAtlasMapCoords*)malloc(sizeof(SPTexAtlasMapCoords)*header->nMaps);
            NSRange coordRange = NSMakeRange(sizeof(SPTextureAtlasHeader), sizeof(SPTexAtlasMapCoords)*header->nMaps);
            [hiResData getBytes:coord range:coordRange];
            
            // half all the coords
            for (int i=0; i<header->nMaps; ++i) {
                coord[i].x /= 2;
                coord[i].y /= 2;
                coord[i].w /= 2;
                coord[i].h /= 2;
            }
            
            NSMutableData *scaledData = [NSMutableData dataWithCapacity:[hiResData length]];
            [scaledData appendBytes:header length:sizeof(SPTextureAtlasHeader)];
            [scaledData appendBytes:coord length:sizeof(SPTexAtlasMapCoords)*header->nMaps];
            free(coord);
            
            someAtlasData = scaledData;
        }
    }
    
    if (anImage) {		
        // get the png data
		NSBitmapImageRep *rep = [[anImage representations] objectAtIndex:0];
		
		NSDictionary *properties = [NSDictionary dictionary];
		NSData *imageData = [rep representationUsingType:NSPNGFileType properties:properties];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"compress"]) {
            // save image data to a temp file that can be compressed by optipng
            NSString *path = [@"~/Library/Application Support/Specter/Texture Packager/tmp/" stringByExpandingTildeInPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:path]) {
                NSError *error = nil;
                [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
                if (error != nil) {
                    NSLog(@"Error creating Temp Directory: %@", error);
                }
            }
            
            path = [path stringByAppendingPathComponent:@"tmp.png"];
            [imageData writeToFile:path atomically:YES];
            
            NSString *optiPath = [[NSBundle mainBundle] pathForResource:@"optipng" ofType:nil];
            NSString *command = [NSString stringWithFormat:@"\"%@\" -o7 \"%@\"", optiPath, path];
            
            // run the unix shell script
            system([command UTF8String]);
            
            // read the compressed file
            imageData = [NSData dataWithContentsOfFile:path];
        }
        
        
        if (someAtlasData) {
            uint32_t pngLen = imageData.length;
            [someAtlasData replaceBytesInRange:NSMakeRange(sizeof(uint32_t)*2, sizeof(uint32_t)) withBytes:&pngLen];
            
            // merge image and altas data into one chunk
            NSMutableData *atlasFileData = [NSMutableData dataWithCapacity:someAtlasData.length+pngLen];
            
            [atlasFileData appendData:someAtlasData];
            [atlasFileData appendData:imageData];
            imageData = atlasFileData;
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"encrypt"]) {
            imageData = [imageData SPData];
        }

		return imageData;
	}
	return nil;
}

- (NSString*)phoneHiName {
    return image[InfoImagePhoneHi].name;
}

- (NSString*)phoneLoName {
    return image[InfoImagePhoneLo].name;
}

- (NSString*)padHiName {
    return image[InfoImagePadHi].name;
}

- (NSString*)padLoName {
    return image[InfoImagePadLo].name;
}
@end
