//
//  AppController.h
//  Texture Packager
//
//  Created by Jonathan on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageInfo;
@interface AppController : NSObject <NSApplicationDelegate> {
	NSUInteger		previewIndex;
	
	NSMutableArray	*imageInfos;
	NSString		*imageFolder;
	
	NSArrayController	*arrCntrl;
	
	NSTextField			*wField, *hField, *aField;
	NSImageView			*imageView;
	
}
@property  IBOutlet NSArrayController *arrCntrl;

@property  IBOutlet NSTextField	*wField;
@property  IBOutlet NSTextField	*hField;
@property  IBOutlet NSTextField	*aField;
@property  IBOutlet NSImageView *imageView;

@property  NSString *imageFolder;
@property  NSArray *imageInfos;
- (IBAction)showImageFolderPanel:(id)sender;
- (ImageInfo*)imageInfoWithName:(NSString*)name inArray:(NSArray*)infoArray;

- (IBAction)export:(id)sender;

- (IBAction)loadTest:(id)sender;
@end
