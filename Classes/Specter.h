/*
 *  Specter.h
 *  Specter
 *
 *  Created by Jonathan on 3/16/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

// os support
#define __SPECTER__ 1


#if TARGET_OS_IPHONE
	#import <OpenGLES/ES1/gl.h>
	#import <OpenGLES/ES1/glext.h>
#else
	#import <OpenGL/gl.h>
#endif

#import "SPTypes.h"
#import "SPGeometry.h"
#import "SPNode.h"
#import "SPTexture.h"
#import "SPTexturePack.h"
#import "SPDrawableNode.h"
#import "SPAnimation.h"
#import "SPSprite.h"
#import "SPCamera.h"
#import "SPLayer.h"
#import "SPScene.h"
#import "SPLabel.h"



