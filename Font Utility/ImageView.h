//
//  ImageView.h
//  Texture Utility
//
//  Created by Jonathan on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ImageView : NSView {
@private
	NSImage			*_image;

}
@property (nonatomic) NSImage *image;
- (id)initWithImage:(NSImage*)image;
@end
