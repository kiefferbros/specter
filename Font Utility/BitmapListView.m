//
//  BitmapListView.m
//  Font Utility
//
//  Created by Jonathan on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BitmapListView.h"


@implementation BitmapListView
- (void)awakeFromNib {
}

- (void)copy:(id)sender {
	if ([self selectedRow] >= 0) {
        id del = [self delegate];
		if (del && [del respondsToSelector:@selector(tableViewWillCopyImage:)]) {
			NSPasteboard *pboard = [NSPasteboard generalPasteboard];
            [pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeTIFF] owner:self];
			NSImage *image = [del tableViewWillCopyImage:self];
            NSData *data = [image TIFFRepresentation];
            
			if ([pboard setData:data forType:NSPasteboardTypeTIFF])
				NSLog(@"image: %@", image);
			else {
				NSLog(@"no image copied:, %@", image);
			}
		}
		
	 }
}

- (void)paste:(id)sender {
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	NSData *data = [pboard dataForType:NSPasteboardTypeTIFF];
	if (data && [self selectedRow] >= 0) {
		NSImage *image = [[NSImage alloc] initWithData:data];
		
		id del = [self delegate];
		if (del && [del respondsToSelector:@selector(tableView:didPasteImage:)]) {
			[del tableView:self didPasteImage:image];
		}
		
	}
}

- (void)delete:(id)sender {
	if ([self selectedRow] >= 0) {
        id del = [self delegate];
		if (del && [del respondsToSelector:@selector(tableViewWillDelete:)]) {
			[del tableViewWillDelete:self];
		}
	}
}
@end
