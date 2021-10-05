//
//  AppController.m
//  Font Utility
//
//  Created by Jonathan on 6/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "GLView.h"
#import "MyDocument.h"

@implementation AppController
@synthesize hardwareContext=hwContext, pixelFormat;
- (void)awakeFromNib {
	
	// open gl shared context
	pixelFormat = [GLView defaultPixelFormat];
	if (pixelFormat) {
		hwContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];		
		[hwContext makeCurrentContext];
	}
}


- (IBAction)export:(id)sender {
	MyDocument *doc= [[[NSApp mainWindow] windowController] document];
	
	
	if (doc.hiResTexture) {
		[exportOptionsView setEnabled:YES];
		[exportOptionsView selectCellWithTag:0];
	} else {
		[exportOptionsView setEnabled:NO];
		[exportOptionsView selectCellWithTag:2];
	}
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAccessoryView:exportOptionsView];
	[savePanel setPrompt:@"Export"];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"spfont"]];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel setExtensionHidden:NO];
	[savePanel beginSheetForDirectory:nil
								 file:[[[doc displayName] stringByDeletingPathExtension] stringByAppendingPathExtension:@"spfont"]
					   modalForWindow:[NSApp mainWindow]
						modalDelegate:self
					   didEndSelector:@selector(exportPanelDidEnd:returnCode:contextInfo:)
						  contextInfo:NULL];
}

- (NSString*)_hiResPathForPath:(NSString*)path {
	NSString *name = [path lastPathComponent];
	
	NSRange searchRange = [name rangeOfString:@"@2x"];
	if (searchRange.location == NSNotFound) {
		// search for 2x file
		NSString *newName = [name stringByDeletingPathExtension];
		newName = [newName stringByAppendingString:@"@2x"];
		newName = [newName stringByAppendingPathExtension:[name pathExtension]];
		
		path = [path stringByDeletingLastPathComponent];
		path = [path stringByAppendingPathComponent:newName];
	}
		
	NSLog(@"%@", path);
	
	
	return path;
}

- (NSString*)_loResPathForPath:(NSString*)path {
	
	path = [path stringByReplacingOccurrencesOfString:@"@2x" withString:@""];

	NSLog(@"%@", path);
	
	return path;
}



- (void)_exportFontToPath:(NSString*)path hiRes:(BOOL)hiRes {
	path = (hiRes) ? [self _hiResPathForPath:path] : [self _loResPathForPath:path];
	
	MyDocument *doc= [[[NSApp mainWindow] windowController] document];
	if ([[doc fontData:hiRes showPreview:NO compress:YES] writeToFile:path atomically:YES])
		NSLog(@"successful export");
	else {
		NSBeep();
		NSLog(@"unsuccessful export");
	}
}

- (void)exportPanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton) {
		
		NSString *path = [[[sheet URL] path] stringByExpandingTildeInPath];
		
		switch ([[exportOptionsView selectedCell] tag]) {
			case 0:
				[self _exportFontToPath:path hiRes:YES];
				[self _exportFontToPath:path hiRes:NO];
				break;
			case 1:
				[self _exportFontToPath:path hiRes:YES];
				break;
			case 2:
				[self _exportFontToPath:path hiRes:NO];
				break;
		}
	}
	[sheet orderOut:self];
}
@end
