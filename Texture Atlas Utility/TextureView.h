//
//  TextureView.h
//  Texture Utility
//
//  Created by Jonathan on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Subtexture;
@interface TextureView : NSView {
@private
	NSPoint			_lastLocation;
    CGFloat         _scale;
    NSSize          _actualSize;
}
@property (nonatomic, strong) NSArray *selectedSubtextures;
@property (nonatomic, strong) NSMutableArray *subtextures;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) NSSize actualSize;
- (void)makeDragDestination;
- (void)deselectAll;
- (void)addToSelection:(Subtexture*)texture;
- (void)removeFromSelection:(Subtexture*)texture;
@end

