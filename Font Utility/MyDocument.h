//
//  MyDocument.h
//  Font Utility
//
//  Created by Jonathan on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "BitmapListView.h"
@class GLView, ImageView;
@interface MyDocument : NSDocument
{
	NSMutableDictionary		*bitmapCharacters; // dictionary of bitmap characters
	float					spaceWidth, tabWidth, defaultTracking, defaultLeading, size;
	
	BOOL					hiResTexture, padTexture, autocrop;
	
	id						__unsafe_unretained selectedCharacter;
	
	NSMutableDictionary		*previewInfo;
	
	NSArray					*characters; // NSString objects
	
	IBOutlet GLView			*previewView;
	IBOutlet ImageView		*textureView;
	
	IBOutlet NSTextField	*dimensionField;
	
}
@property (assign) float spaceWidth, tabWidth;
@property (assign) BOOL hiResTexture, padTexture, autocrop;
@property (unsafe_unretained) id selectedCharacter;
@property (readonly) NSMutableDictionary *previewInfo;

- (NSData*)fontData:(BOOL)hiRes showPreview:(BOOL)showPreview compress:(BOOL)compress;

- (IBAction)buildPreviewFont:(id)sender;

- (IBAction)updatePreview:(id)sender;

- (IBAction)syncTracking:(id)sender;
- (IBAction)syncLeading:(id)sender;
@end
