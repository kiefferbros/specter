//
//  BitmapCharacter.h
//  Font Utility
//
//  Created by Jonathan on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPLabel.h"

enum  {
    kHiResCharForHiResTex = 0,
    kLoResCharForHiResTex,
    kLoResCharForLoResTex
};

@interface BitmapCharacter : NSObject <NSCoding> {
	NSImage *image;
	SPFloat frontPad, backPad, offsetY;
}
@property (readonly) SPFloat width, height;
@property (readonly) NSImage *image;
@property (assign) SPFloat frontPad, backPad, offsetY;

- (id)initWithBitmapImage:(NSImage*)img crop:(BOOL)crop;


// returns NSImage with the appropriate adjustments to accomodated for half point offsets and padding
- (NSImage *)alignedImageWithCharInfo:(inout SPCharInfo *)info option:(NSUInteger)option;
@end
