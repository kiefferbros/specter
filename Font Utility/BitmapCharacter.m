//
//  BitmapCharacter.m
//  Font Utility
//
//  Created by Jonathan on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BitmapCharacter.h"

@implementation BitmapCharacter
@synthesize frontPad, backPad, offsetY;
@synthesize image;
@dynamic width, height;

- (id)initWithBitmapImage:(NSImage*)img crop:(BOOL)crop{
	if ((self = [super init])) {
        if (crop) {
            // crop out clear pixels
            int                 w, h, l, b, r, t;
            NSBitmapImageRep    *rep;
            NSRect              sourceRect;
            
            rep = [[img representations] objectAtIndex:0];
            
            w = [rep pixelsWide];
            h = [rep pixelsHigh];
            l = w;
            b = h;
            r = 0;
            t = 0;
            
            
            for (int x=0; x<w; ++x) {
                for (int y=0; y<h; ++y) {
                    NSColor *color = [rep colorAtX:x y:y];
                    if ([color alphaComponent] > 0.) {
                        l = MIN(l, x);
                        r = MAX(r, x+1);
                        
                        b = MIN(b, y);
                        t = MAX(t, y+1);
                    }
                }
            }           
            
            if (r<=l || t<=b) {
                return nil;
            }
            
            sourceRect = NSMakeRect(l, h-t, r-l, t-b);
            image = [[NSImage alloc] initWithSize:sourceRect.size];
            
            [image lockFocus];
            [img drawAtPoint:NSZeroPoint fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.];
            [image unlockFocus];
        } else {
            image = img;
        }

	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		image = [aDecoder decodeObjectForKey:@"image"];
		
		if ([aDecoder containsValueForKey:@"offsetX"]) {
			frontPad = [aDecoder decodeFloatForKey:@"offsetX"];
		} else {
			frontPad = [aDecoder decodeFloatForKey:@"frontPad"];
			backPad = [aDecoder decodeFloatForKey:@"backPad"];
		}
		
		offsetY = [aDecoder decodeFloatForKey:@"offsetY"];		   
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:image forKey:@"image"];
	[aCoder encodeFloat:frontPad forKey:@"frontPad"];
	[aCoder encodeFloat:backPad forKey:@"backPad"];
	[aCoder encodeFloat:offsetY forKey:@"offsetY"];
}


- (SPFloat)width {
	return [image size].width;
}

- (SPFloat)height {
	return [image size].height;
}

- (NSImage *)alignedImageWithCharInfo:(inout SPCharInfo *)info option:(NSUInteger)option {
    
    if (option <= kLoResCharForHiResTex) {        
        CGFloat w, h, x, y, s;
        s = option == kLoResCharForHiResTex ? 0.5 :  1.;
        x = 0.;
        y = 0.;
        w = image.size.width;
        h = image.size.height;
        
        if ((int)image.size.width%2 != 0) {
            w =  image.size.width+1.;
        }
        
        if ((int)image.size.height%2 != 0) {
			h = image.size.height+1.;		
		}
        
        if ((int)roundf(info->frontPad/0.5f)%2!=0) {
            x = 1.;
            info->frontPad = floorf(info->frontPad);
            if (image.size.width == w)
                w += 2.;
        }
        
        if ((int)roundf(info->offsetY/0.5f)%2!=0) {
            y = 1.;
            info->offsetY = floorf(info->offsetY);
            if (image.size.height == h)
                h += 2.;
        }        
        
        NSImage *alignedImage = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];         
                 
        [alignedImage lockFocus];
        [image drawAtPoint:NSMakePoint(x, y) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        [alignedImage unlockFocus];
        
        info->width = w*s;
        info->height = h*s;
        info->backPad = roundf(info->backPad);
        
        return alignedImage;
    }
    
    info->width = image.size.width;
    info->height = image.size.height;
    
    return image;
}
@end
