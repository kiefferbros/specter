//
//  ImageView.m
//  Texture Utility
//
//  Created by Jonathan on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageView.h"


@implementation ImageView

@dynamic image;

- (id)initWithImage:(NSImage*)image {
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        // Initialization code here.
		self.image = image;
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
	NSDrawGroove(self.bounds, dirtyRect);
	[_image drawInRect:NSInsetRect(self.bounds, 5., 5.) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
}

- (void)setImage:(NSImage *)image {
	_image = image;
	
	//[self setFrameSize:NSMakeSize(image.size.width, image.size.height)];
	
	[self setNeedsDisplay:YES];
}

- (NSImage*)image {
	return _image;
}

@end
