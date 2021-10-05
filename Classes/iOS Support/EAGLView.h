//
//  EAGLView.h
//  LookSee
//
//  Created by Jonathan on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGLDrawable.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "SPGeometry.h"

BOOL CheckForGLExtension(NSString *searchName);

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@class EAGLView;
@protocol EAGLViewDelegate <NSObject>

- (void)drawFrameInEAGLView:(EAGLView*)view;

- (void)EAGLView:(EAGLView*)aView  touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)EAGLView:(EAGLView*)aView  touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)EAGLView:(EAGLView*)aView  touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)EAGLView:(EAGLView*)aView  touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;

@end

@interface EAGLView : UIView
{
@package
    EAGLContext *context;
    
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer;
	
	CADisplayLink *__unsafe_unretained displayLink;
	id <EAGLViewDelegate> __unsafe_unretained delegate;
	BOOL linkedToDisplay;
	NSInteger displayLinkInterval;
    
    BOOL linkedOnPause;
}
@property (nonatomic, unsafe_unretained) id <EAGLViewDelegate> delegate;
@property (nonatomic, readonly, getter=isLinkedToDisplay) BOOL linkedToDisplay;
@property (unsafe_unretained, nonatomic, readonly) CADisplayLink *displayLink;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, readonly) SPTime timeInterval;
@property (nonatomic, readonly) SPBox framebufferViewport;

@property (nonatomic) NSInteger displayLinkInterval;

- (void)bindFramebuffer;
- (BOOL)presentFramebuffer;

- (void)drawFrame:(CADisplayLink*)aDisplayLink ;

- (void)startDisplayLink;
- (void)stopDisplayLink;

- (void)pauseDisplayLink;
- (void)resumeDisplayLink;

- (SPVec2)locationForTouch:(UITouch*)touch;
@end



