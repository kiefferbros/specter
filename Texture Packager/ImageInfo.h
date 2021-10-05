//
//  ImageInfo.h
//  Texture Package Maker
//
//  Created by Jonathan on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum _InfoImage {
	InfoImagePhoneLo,
	InfoImagePhoneHi,
	InfoImagePadLo,
    InfoImagePadHi
} InfoImage;

@interface ImageInfo : NSObject {
	NSString	*name;
    
    NSImage     *image[4];
    NSData      *atlasData[4];	
}
@property 	NSString *name;
@property (readonly) NSString *phoneHiName, *phoneLoName, *padHiName, *padLoName;

- (id)initWithName:(NSString*)aName;

- (void)loadImage:(InfoImage)imageID atPath:(NSString*)path;
- (NSData*)imageData:(InfoImage)imageID;
- (NSImage*)image:(InfoImage)imageID;

- (NSData*)atlasData:(InfoImage)imageID;
@end
