//
//  AppController.h
//  Font Utility
//
//  Created by Jonathan on 6/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	NSOpenGLContext *hwContext;
	NSOpenGLPixelFormat *pixelFormat;
	
	IBOutlet NSMatrix *exportOptionsView;
}
@property(readonly) NSOpenGLContext *hardwareContext;
@property(readonly) NSOpenGLPixelFormat *pixelFormat;

- (IBAction)export:(id)sender;
@end
