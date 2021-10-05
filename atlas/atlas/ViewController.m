//
//  ViewController.m
//  atlas
//
//  Created by Jonathan Kieffer on 3/30/12.
//  Copyright (c) 2012 Kieffer Bros., LLC. All rights reserved.
//

#import "ViewController.h"
#import "SceneController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.sceneController = [[SceneController alloc] init];
    [self.glView startDisplayLink];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
