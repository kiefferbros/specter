//
//  BitmapListView.h
//  Font Utility
//
//  Created by Jonathan on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BitmapListView : NSTableView {

}

@end

@interface NSObject (BitmapListViewDelegate)
- (void)tableView:(NSTableView*)aTableView didPasteImage:(NSImage*)image;
- (void)tableViewWillDelete:(NSTableView*)aTableView;
- (NSImage*)tableViewWillCopyImage:(NSTableView*)aTableView;
@end