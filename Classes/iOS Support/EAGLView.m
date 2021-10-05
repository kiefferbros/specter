//
//  EAGLView.m
//  LookSee
//
//  Created by Jonathan on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EAGLView.h"

BOOL CheckForGLExtension(NSString *searchName)
{
	// For performance, the array can be created once and cached.
    NSString *extensionsString = [NSString stringWithCString:(const char*)glGetString(GL_EXTENSIONS) encoding: NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: searchName];
}

@interface EAGLView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)initView;
@end

@implementation EAGLView

@dynamic context;
@synthesize displayLink;
@synthesize delegate;
@synthesize linkedToDisplay;
@dynamic timeInterval;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self)
    {
        [self initView]; 
    }
    return self;
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:.
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self)
    {
        [self initView];
    }
    
    return self;
}

- (void)initView {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    // retina display support
    if ([self respondsToSelector:@selector(contentScaleFactor)]) {
        self.contentScaleFactor = [UIScreen mainScreen].scale;
    }
    
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];
    
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [self setContext:aContext];
    
    displayLinkInterval = 1;
    
    [self bindFramebuffer];
}

- (void)dealloc
{
    [self deleteFramebuffer];    
    
}

- (EAGLContext *)context
{
    return context;
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext)
    {
        [self deleteFramebuffer];
        
        context = newContext;
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
    if (context && !defaultFramebuffer)
    {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object.
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer *)self.layer];
        
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
		
		
		CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
		CGFloat					scale = 1.0;
		CGSize					newSize;
		
		if ([self respondsToSelector:@selector(contentScaleFactor)]) 
			scale = self.contentScaleFactor;
		
		
		newSize = eaglLayer.bounds.size;
		framebufferWidth = roundf(newSize.width*scale);
		framebufferHeight = roundf(newSize.height*scale);
		
        //glGetRenderbufferOParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        //glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
        
        if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    }
}

- (void)deleteFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer)
        {
            glDeleteFramebuffersOES(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffersOES(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (void)bindFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (!defaultFramebuffer)
            [self createFramebuffer];
        
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    }
}


- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    }
    
    return success;
}

- (SPBox)framebufferViewport {
    return SPBoxMake(0, 0, framebufferWidth, framebufferHeight);
}


- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

- (void)drawFrame:(CADisplayLink*)aDisplayLink {
	[delegate drawFrameInEAGLView:self];
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	[delegate EAGLView:self touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	[delegate EAGLView:self touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	[delegate EAGLView:self touchesMoved:touches withEvent:event];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[delegate EAGLView:self touchesBegan:touches withEvent:event];
}


- (NSInteger)displayLinkInterval
{
    return displayLinkInterval;
}

- (void)setDisplayLinkInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        displayLinkInterval = frameInterval;
        
        if (linkedToDisplay)
        {
            [self stopDisplayLink];
            [self startDisplayLink];
        }
    }
}

- (void)startDisplayLink {
	if (!linkedToDisplay)
    {
        CADisplayLink *aDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame:)];
        [aDisplayLink setFrameInterval:displayLinkInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		displayLink = aDisplayLink;
        
        linkedToDisplay = TRUE;
    }
}

- (void)stopDisplayLink {
	if (linkedToDisplay)
    {
        [displayLink invalidate];
		displayLink = nil;
        linkedToDisplay = FALSE;
    }
}

- (void)pauseDisplayLink {
    linkedOnPause = linkedToDisplay;
    [self stopDisplayLink];
}
- (void)resumeDisplayLink {
    if (linkedOnPause) {
        [self startDisplayLink];
    }
}

- (SPVec2)locationForTouch:(UITouch*)touch {
	CGPoint location = [touch locationInView:self];
	SPVec2 screen = SPVec2Make(location.x, self.bounds.size.height-location.y);
	return screen;
}

- (SPTime)timeInterval {
    return (linkedToDisplay) ? displayLinkInterval*displayLink.duration : 0.;
}
@end
