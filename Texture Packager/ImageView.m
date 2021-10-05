//
//  ImageView.m
//  Texture Utility
//
//  Created by Jonathan on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageView.h"


@implementation ImageView

- (id)initWithImage:(NSImage*)image {
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        // Initialization code here.
		self.image = image;
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
	// maintain aspect ratio
	NSRect rect;
	NSSize boundSize = self.bounds.size;
	NSSize size = _image.size;
	NSSize newSize;
	
	if (size.width > boundSize.width || size.height > boundSize.height) {
		if (size.width > size.height) {
			CGFloat ratio = size.width/size.height;
			
			newSize.width = boundSize.width;
			newSize.height = round(ratio*newSize.width);
			
		} else if (size.height > size.width) {
			CGFloat ratio = size.height/size.width;
			
			newSize.height = boundSize.height;
			newSize.width = round(ratio*newSize.height);
		} else {
			newSize = boundSize;
		}
	} else {
		newSize = size;
	}
	
	rect = NSMakeRect(round((boundSize.width-newSize.width)/2.0), round((boundSize.height-newSize.height)/2.0), newSize.width, newSize.height);
	
	[_image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)setImage:(NSImage *)image {
	_image = image;
	
	[self setFrameSize:NSMakeSize(image.size.width, image.size.height)];
	
	[self setNeedsDisplay:YES];
}

- (NSImage*)image {
	return _image;
}

@end
