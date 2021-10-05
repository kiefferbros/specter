//
//  SceneController.h
//  MonsterSoup
//
//  Created by Jonathan on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAGLViewController.h"
#import "Specter.h"


@class SPScene, EAGLViewController;
@interface SPSceneController : NSObject <EAGLViewDelegate> {
@private
	EAGLViewController		*__unsafe_unretained viewController;
	SPScene					*scene;
}
@property (unsafe_unretained, nonatomic, readonly) EAGLViewController *viewController;
@property (nonatomic, strong) SPScene *scene;
@property (nonatomic, readonly) NSInteger tag;

- (void)drawSceneInView;

- (void)sceneWillAppear:(BOOL)animated;
- (void)sceneDidAppear:(BOOL)animated;
- (void)sceneWillDisappear:(BOOL)animated;
- (void)sceneDidDisappear:(BOOL)animated;

- (SPVec2)globalPositionForTouch:(UITouch*)touch;
@end