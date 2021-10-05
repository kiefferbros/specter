//
//  TextureView.m
//  Texture Utility
//
//  Created by Jonathan on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TextureView.h"
#import "Subtexture.h"


@implementation TextureView

@synthesize subtextures = _subtextures;
@synthesize selectedSubtextures = _selectedSubtextures;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		//_selectedSubtextures = [[NSArray alloc] init];
        //_subtextures = [[NSMutableArray alloc] init];
        _scale = 1.;
        _actualSize = frame.size;
        
        [self addObserver:self forKeyPath:@"selectedSubtextures" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"subtextures" options:0 context:NULL];
    }
    return self;
}

- (void)dealloc  {
    [self removeObserver:self forKeyPath:@"selectedSubtextures"];
    [self removeObserver:self forKeyPath:@"subtextures"];
	[self unregisterDraggedTypes];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    // Drawing code here.
	[[NSColor darkGrayColor] set];
	NSRectFill(dirtyRect);
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleBy:_scale];
    [transform concat];
    
    for (Subtexture *tex in _subtextures) {
        
        [tex.image drawAtPoint:tex.position fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.];
        
        if ([_selectedSubtextures containsObject:tex]) [[NSColor colorWithCalibratedRed:0.0 green:0.2 blue:0.8 alpha:1.0] set];
        else [[NSColor blackColor] set];
        
        NSRect frame = tex.frame;
        
        NSRect rect;
        rect = frame;
        rect.size.width = (1./_scale);
        NSRectFill(rect);
        
        rect = frame;
        rect.origin.x += rect.size.width-(1./_scale);
        rect.size.width = (1./_scale);
        NSRectFill(rect);
        
        rect = frame;
        rect.size.height = (1./_scale);
        NSRectFill(rect);
        
        rect = frame;
        rect.origin.y += rect.size.height-(1./_scale);
        rect.size.height = (1./_scale);
        NSRectFill(rect);
    }

}

- (BOOL)isOpaque {
	return YES;
}

- (void)makeDragDestination {
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender {
	return [self draggingUpdated:sender];
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender {
	NSPasteboard *pboard = [sender draggingPasteboard];	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
        for (NSString *file in files) {
			if (![[file pathExtension] isEqualToString:@"png"]) {
				return NSDragOperationNone;
			}
		}
		
		return NSDragOperationCopy;
        // Perform operation using the list of files
    }
	
	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
	NSPoint localPoint = [self convertPoint:[sender draggingLocation] fromView:nil];
    localPoint.x /= _scale;
    localPoint.y /= _scale;
	NSPasteboard *pboard = [sender draggingPasteboard];	
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        [self deselectAll];
		for (NSString *file in files) {
			// add image view
			NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
            NSString *name = [[file lastPathComponent] stringByDeletingPathExtension];
            if (![image setName:name]) {
                [image setName:[NSString stringWithFormat:@"%@-1", name]];
            }
            
            Subtexture *texture = [[Subtexture alloc] initWithImage:image];
			texture.position = localPoint;
			localPoint.x += 10;
			localPoint.y += 10;
            
            NSDictionary *info = [self infoForBinding:@"subtextures"];
            NSArrayController *cntrl = [info objectForKey:NSObservedObjectKey];
            [cntrl addObjects:[NSArray arrayWithObject:texture]];		
			//[self addToSelection:texture];			
		}
    }
	
	return YES;
}

- (NSSize)actualSize {
    return _actualSize;
}

- (void)setActualSize:(NSSize)actualSize {
    if (!NSEqualSizes(actualSize, _actualSize)) {
        _actualSize = actualSize;
        [self setFrameSize:NSMakeSize(_actualSize.width*_scale, _actualSize.height*_scale)];
    }
}

- (CGFloat)scale {
    return _scale;
}

- (void)setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        [self setFrameSize:NSMakeSize(_actualSize.width*_scale, _actualSize.height*_scale)];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay:YES];
}

- (void)deselectAll {
	NSDictionary *info = [self infoForBinding:@"selectedSubtextures"];
    NSArrayController *cntrl = [info objectForKey:NSObservedObjectKey];
    [cntrl removeSelectedObjects:[cntrl selectedObjects]];
}

- (void)addToSelection:(Subtexture*)texture {
    NSDictionary *info = [self infoForBinding:@"selectedSubtextures"];
    NSArrayController *cntrl = [info objectForKey:NSObservedObjectKey];
    [cntrl addSelectedObjects:[NSArray arrayWithObject:texture]];
}

- (void)removeFromSelection:(Subtexture*)texture {
    NSDictionary *info = [self infoForBinding:@"selectedSubtextures"];
    NSArrayController *cntrl = [info objectForKey:NSObservedObjectKey];
    [cntrl removeSelectedObjects:[NSArray arrayWithObject:texture]];
}

- (void)mouseDown:(NSEvent*)event {
	NSPoint		window, local;
	Subtexture  *texture = nil;
	
	[[self window] makeFirstResponder:self];
	
	window = [event locationInWindow];
	local = [self convertPoint:window fromView:nil];
	
	_lastLocation = local;
	
	for (Subtexture *tex in _subtextures.reverseObjectEnumerator) {
        NSRect frame =tex.frame;
        frame.origin.x *= _scale;
        frame.origin.y *= _scale;
        frame.size.width *= _scale;
        frame.size.height *= _scale;
        if (NSPointInRect(local, frame)) {
            texture = tex;
            break;
        }
    }
	
	if ([NSEvent modifierFlags] == NSShiftKeyMask) {

		
		if ([[self mutableArrayValueForKey:@"selectedSubtextures"] containsObject:texture]) {
			[self removeFromSelection:(Subtexture*)texture];
			return;
		}
		
	} else {
		if (texture == nil) {
			[self deselectAll];
			return;
		}
		
		if (![[self mutableArrayValueForKey:@"selectedSubtextures"] containsObject:texture])
			[self deselectAll];
		else
			return;	
	}
	
	[self addToSelection:texture];
}


- (void)mouseDragged:(NSEvent *)event {
	if (![[self mutableArrayValueForKey:@"selectedSubtextures"] count]) return;
	
	NSPoint	window, local, delta;
	
	window = [event locationInWindow];
	local = [self convertPoint:window fromView:nil];
	
	delta.x = local.x - _lastLocation.x;
	delta.y = local.y - _lastLocation.y;
	
    
	for (Subtexture *tex in [self mutableArrayValueForKey:@"selectedSubtextures"]) {
		NSPoint origin = tex.position;
		origin.x += delta.x/_scale;
		origin.y += delta.y/_scale;
		
		tex.position = origin;
	}
    
    [self setNeedsDisplay:YES];
	
	_lastLocation = local;
}

- (void)keyDown:(NSEvent *)event {
	if (![[self mutableArrayValueForKey:@"selectedSubtextures"] count]) return;
	
	NSString *chars = [event characters];
    unichar character = [chars characterAtIndex: 0];
	
    if (character == NSDeleteCharacter) {
        NSDictionary *info = [self infoForBinding:@"selectedSubtextures"];
        NSArrayController *cntrl = [info objectForKey:NSObservedObjectKey];
        [cntrl removeObjects:[cntrl selectedObjects]];		
		return;
    }
	
	if (character == NSRightArrowFunctionKey) {
		for (Subtexture *tex in [self mutableArrayValueForKey:@"selectedSubtextures"]) {
            tex.x += 1.;
		}
        [self setNeedsDisplay:YES];
	}
	
	if (character == NSLeftArrowFunctionKey) {
		for (Subtexture *tex in [self mutableArrayValueForKey:@"selectedSubtextures"]) {
            tex.x -= 1.;
		}
        [self setNeedsDisplay:YES];
	}
	
	if (character == NSUpArrowFunctionKey) {
		for (Subtexture *tex in [self mutableArrayValueForKey:@"selectedSubtextures"]) {
            tex.y += 1.;
		}
        [self setNeedsDisplay:YES];
	}
	
	if (character == NSDownArrowFunctionKey) {
		for (Subtexture *tex in [self mutableArrayValueForKey:@"selectedSubtextures"]) {
            tex.y -= 1.;
		}
        [self setNeedsDisplay:YES];
	}
}

@end

