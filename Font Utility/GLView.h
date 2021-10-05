//
//  GLView.h
//  SpecterEditor
//
//  Created by Jonathan on 4/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Specter.h"

@class GLView;
@protocol GLViewDelegate <NSObject> 
@optional
- (void)glView:(GLView*)glView didReshapeToSize:(CGSize)size;
- (void)glViewDidPrepare:(GLView*)glView;
@end

@interface GLView : NSOpenGLView {
@private
	id<GLViewDelegate>	_delegate;
	NSPoint				_lastLoc;
	BOOL				_prepared;

    //NSOpenGLContext*     _openGLContext;
   // NSOpenGLPixelFormat* _pixelFormat;
	
	SPScene		*_scene;
	SPLabel		*_label;
}
@property (readonly) SPLabel *label;
@property(nonatomic) IBOutlet id<GLViewDelegate> delegate;
- (void)makeContextCurrent;
- (void)swapBuffers;
- (BOOL)isPrepared;

- (void)drawScene;
@end
