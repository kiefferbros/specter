//
//  SceneController.m
//  MonsterSoup
//
//  Created by Jonathan on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SPSceneController.h"
//#import "EAGLViewController.h"

@interface SPSceneController ()
- (void)_setViewController:(EAGLViewController*)aController;
@end

@implementation SPSceneController

@synthesize scene;

- (id)init {
    if ((self = [super init])) {
        SPScene *aScene = [[SPScene alloc] init];
        self.scene = aScene;
    }
    return self;
}

- (EAGLViewController *)viewController {
	return viewController;
}

- (void)_setViewController:(EAGLViewController *)aController {
	viewController = aController;
}


- (void)drawSceneInView {
	[self.viewController.glView bindFramebuffer];
	[self.scene draw];
	[self.viewController.glView presentFramebuffer];
}

- (SPVec2)globalPositionForTouch:(UITouch*)touch {
	SPVec2 screen = [self.viewController.glView locationForTouch:touch];
	return [self.scene.camera screenToGlobal:screen];
	
}

- (NSInteger)tag {
    return 0;
}

#pragma mark -
#pragma mark EAGLViewDelegate
- (void)drawFrameInEAGLView:(EAGLView*)view {
    [self.scene stepNodeAnimations:view.timeInterval];
	[self.scene draw];
}

- (void)EAGLView:(EAGLView*)aView  touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {

}

- (void)EAGLView:(EAGLView*)aView  touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	
}

- (void)EAGLView:(EAGLView*)aView  touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	
}

- (void)EAGLView:(EAGLView*)aView  touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	
}

#pragma mark -
#pragma mark Transitions
- (void)sceneWillAppear:(BOOL)animated {
    CGSize s = self.viewController.glView.bounds.size;
	[self.scene.camera reshapeWithSize:SPVec2Make(s.width, s.height) viewport:self.viewController.glView.framebufferViewport];
}

- (void)sceneDidAppear:(BOOL)animated {
	
}

- (void)sceneWillDisappear:(BOOL)animated {
	
}

- (void)sceneDidDisappear:(BOOL)animated {
	
}
@end

