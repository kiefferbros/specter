//
//  GLView.m
//  SpecterEditor
//
//  Created by Jonathan on 4/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLView.h"
#import "AppController.h"

@implementation GLView


+ (NSOpenGLPixelFormat*)defaultPixelFormat {
	NSOpenGLPixelFormatAttribute hwAttrs[] =
	{
		//NSOpenGLPFAAllRenderers,
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		//NSOpenGLPFADepthSize, 32,
		//NSOpenGLPFADoubleBuffer,
		//NSOpenGLPFAAccelerated,
		//NSOpenGLPFAMinimumPolicy,
		//NSOpenGLPFAClosestPolicy,
		//NSOpenGLPFARendererID, kCGLRendererGenericID,
		//NSOpenGLPFAOffScreen,
		0
	};
	NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:hwAttrs];
	
	return format;
}

@synthesize delegate=_delegate;
@synthesize label=_label;

- (id)initWithCoder:(NSCoder*)coder {
	if ((self = [super initWithCoder:coder])) {
		
		NSOpenGLPixelFormat *format = [(AppController*)[NSApp delegate] pixelFormat];
		if (format) {
			NSOpenGLContext *hwContext = [(AppController*)[NSApp delegate] hardwareContext];
			NSOpenGLContext *context = [[NSOpenGLContext alloc] initWithFormat:format shareContext:hwContext];
			[self setOpenGLContext:context];
			
			[context makeCurrentContext];
		}
	}
	return self;
}


- (BOOL)isPrepared {
	return _prepared;
}

- (void)reshape {
	// tell the document that the view has resized so document camera can resize
	NSSize size = self.frame.size;
    
	[_scene.camera reshapeWithSize:SPVec2Make(size.width,size.height)];
	[self setNeedsDisplay:YES];
	
	if ([_delegate respondsToSelector:@selector(glView:didReshapeToSize:)])
		[_delegate glView:self didReshapeToSize:NSSizeToCGSize(size)];
}

- (void)prepareOpenGL {
	[super prepareOpenGL];
	
	
	
	_scene = [[SPScene alloc] init];
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	
	SPLayer *layer = [SPLayer layer];
	[_scene addChild:layer];
	
	_label = [[SPLabel alloc] initWithText:nil font:nil alignment:SPTextAlignmentLeft];
	_label.position = SPVec2Make(0.0f, self.frame.size.height-30.0f);
	[layer addChild:_label];
	
	
	glClear(GL_COLOR_BUFFER_BIT);
	[self swapBuffers];

	_prepared = YES;
	if ([_delegate respondsToSelector:@selector(glViewDidPrepare:)])
		[_delegate glViewDidPrepare:self];
}


- (void)makeContextCurrent {
	[[self openGLContext] makeCurrentContext];
}

- (void)swapBuffers {
	//[[self openGLContext] update];
	//[[self openGLContext] flushBuffer];
	glFlush();
}

- (void)drawScene;{
	glClear(GL_COLOR_BUFFER_BIT);
	
	glColor4ub(135, 135, 135, 255);
	glDisable(GL_TEXTURE_2D);
	[_scene.camera begin];
	glLineWidth(1.0);
	
	for (int i=0; i<_label.numberOfLines; ++i) {
		// draw a baseline
		glBegin(GL_LINES);
		glVertex2f(0.0f, (self.frame.size.height-30.0f)-i*_label.leading*_label.scale.x);
		glVertex2f(339.0f, (self.frame.size.height-30.0f)-i*_label.leading*_label.scale.x);
		glEnd();
	}
	[_scene.camera end];
	
	glEnable(GL_TEXTURE_2D);
	
	[_scene draw];
	
	[self swapBuffers];
}

- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	_lastLoc = local_point;
}

- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];
	SPVec2 v1 = SPVec2Make(local_point.x, local_point.y);
	SPVec2 v2 = SPVec2Make(_lastLoc.x, _lastLoc.y);
	
	
	_scene.camera.position = SPVec2Add(_scene.camera.position, SPVec2Sub(v2, v1));
	_lastLoc = local_point;
	[self drawScene];
}



@end
