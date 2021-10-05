//
//  EAGLViewController.h
//  MonsterSoup
//
//  Created by Jonathan on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
//#import "SceneController.h"

@class SPSceneController;

@interface EAGLViewController : UIViewController {
@private
	SPSceneController *sceneController;
    EAGLView          *glView;
}
@property (nonatomic, strong) SPSceneController *sceneController;
@property (nonatomic, strong) IBOutlet EAGLView *glView;
@end

