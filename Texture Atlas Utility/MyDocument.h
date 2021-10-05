//
//  MyDocument.h
//  Texture Utility
//
//  Created by Jonathan on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TextureView;
@interface MyDocument : NSDocument <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic) IBOutlet TextureView *textureView;
@property (nonatomic) IBOutlet NSArrayController *subtexturesController;
@property (nonatomic) NSMutableArray *subtextures;
@property (nonatomic) NSMutableArray *selectedSubtextures;
@property (nonatomic) NSUInteger width, height;
@property (nonatomic) IBOutlet NSPanel *divideSheet;
@property (nonatomic) NSUInteger divideColumns, divideRows;
@property (nonatomic) CGFloat scale;
@property (nonatomic, readonly) BOOL canModifySubtexture;
@property (nonatomic) NSUInteger exportScale;

- (IBAction)exportAtlas:(id)sender;

- (IBAction)showDivideSheet:(id)sender;
- (IBAction)hideDividSheet:(id)sender;

- (IBAction)replaceSubtexture:(id)sender;

- (IBAction)refactor:(id)sender;
@end
