//
//  EAGLViewController.m
//  MonsterSoup
//
//  Created by Jonathan on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EAGLViewController.h"
#import "SPSceneController.h"

@interface SPSceneController ()
- (void)_setViewController:(EAGLViewController*)aController;
@end

@implementation EAGLViewController
@synthesize glView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.glView) 
        glView = [[EAGLView alloc] initWithFrame:self.view.bounds];
    
    if (self.view != self.glView)
        [self.view insertSubview:glView atIndex:0];
    
    [glView bindFramebuffer];
}


#pragma mark -
#pragma mark EAGLViewDelegate
//- (EAGLView*)glView {
//	return (EAGLView*)self.view;
//}

- (SPSceneController*)sceneController {
	return sceneController;
}

- (void)setSceneController:(SPSceneController *)aController {
	
	if (sceneController) {
		[sceneController sceneWillDisappear:NO];
		[sceneController sceneDidDisappear:NO];
		[sceneController _setViewController:nil];
	}
	
	sceneController = aController;
	
	self.glView.delegate = sceneController;
	[sceneController _setViewController:self];
	[sceneController sceneWillAppear:NO];
	[sceneController sceneDidAppear:NO];
}

@end
