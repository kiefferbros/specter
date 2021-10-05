//
//  MyDocument.m
//  Texture Utility
//
//  Created by Jonathan on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "TextureView.h"
#import "Subtexture.h"
#import "SPTextureAtlas.h"

@implementation MyDocument
@synthesize subtextures=_subtextures;
@synthesize selectedSubtextures=_selectedSubtextures;
@synthesize subtexturesController=_subtexturesController;
@synthesize textureView = _textureView;
@synthesize width=_width;
@synthesize height=_height;
@synthesize scale=_scale;
@synthesize divideSheet = _divideSheet;
@synthesize divideColumns = _divideColumns;
@synthesize divideRows = _divideRows;
@synthesize exportScale = _exportScale;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
        _width = 1024;
        _height = 1024;
        _scale = 1.;
        _divideColumns = 1;
        _divideRows = 1;
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"width"];
    [self removeObserver:self forKeyPath:@"height"];
    [self removeObserver:self forKeyPath:@"scale"];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	[self.textureView makeDragDestination];
	
    
    self.textureView.actualSize = NSMakeSize(_width, _height);
    
    [self.textureView bind:@"subtextures" toObject:self.subtexturesController withKeyPath:@"arrangedObjects" options:nil];
    [self.textureView bind:@"selectedSubtextures" toObject:self.subtexturesController withKeyPath:@"selectedObjects" options:nil];
    
	//if (_subtextures) {
	//	self.textureView.subtextures = _subtextures;	
	//	_subtextures = nil;
	//}
    
    
    
    [self.textureView makeDragDestination];
    [self addObserver:self forKeyPath:@"width" options:0 context:(__bridge voidPtr)self];
    [self addObserver:self forKeyPath:@"height" options:0 context:(__bridge voidPtr)self];
    [self addObserver:self forKeyPath:@"scale" options:0 context:NULL];
    
    [self.subtexturesController addObserver:self forKeyPath:@"selectedObjects" options:0 context:NULL];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	
	
	NSDictionary *docDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithUnsignedInteger:_width], @"width", 
                             [NSNumber numberWithUnsignedInteger:_height], @"height", 
                             self.textureView.subtextures, @"subtextures", nil];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:docDict];
	
	return data;

}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	NSDictionary *docDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (docDict == nil) {
		if ( outError != NULL ) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
		}
		return NO;
	}
	
    _width = [[docDict objectForKey:@"width"] unsignedIntegerValue];
    _height = [[docDict objectForKey:@"height"] unsignedIntegerValue];
	_subtextures = [docDict objectForKey:@"subtextures"];
	
    return YES;
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	NSWindow *window = [notification object];
	[window makeFirstResponder:self.textureView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context   {
    if ((__bridge id)context == self) {
        self.textureView.actualSize = NSMakeSize(_width, _height);
        
    } else if (object == self.subtexturesController) {
        [self willChangeValueForKey:@"canModifySubtexture"];
        [self didChangeValueForKey:@"canModifySubtexture"];
    } else {
        self.textureView.scale = _scale;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.subtextures.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [NSNumber numberWithInteger:rowIndex];
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboar {
    [aTableView registerForDraggedTypes:[NSArray arrayWithObject:@"SubtextureType"]];
    [pboar setData:[NSKeyedArchiver archivedDataWithRootObject:rowIndexes] forType:@"SubtextureType"];
    
    return YES;
}


- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    return operation==NSTableViewDropOn?NSDragOperationNone:NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {    
    NSArray *__strong objects = [self.subtexturesController selectedObjects];
    
    [self.subtexturesController removeObjects:objects];
    [self.subtexturesController insertObjects:objects atArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(MIN(row,self.subtextures.count), objects.count)]];
    
    return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    [[self.textureView window] makeFirstResponder:self.textureView];
    return YES;
}

- (IBAction)showDivideSheet:(id)sender {
    [NSApp beginSheet:self.divideSheet modalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (IBAction)hideDividSheet:(id)sender {
    [NSApp endSheet:self.divideSheet returnCode:[sender tag]];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSOKButton) {
        NSArray *selectedObjects = self.subtexturesController.selectedObjects;
        Subtexture *tex = [selectedObjects objectAtIndex:0];
        
        NSArray *subs = [tex divideIntoRows:self.divideRows columns:self.divideColumns];
        if (subs) {
            NSUInteger loc = [self.subtexturesController.arrangedObjects indexOfObject:tex];
            [self.subtexturesController insertObjects:subs atArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, subs.count)]];
            [self.subtexturesController removeObjects:[NSArray arrayWithObject:tex]];
        }
        
    }
    
    [sheet orderOut:nil];
}

- (IBAction)replaceSubtexture:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel beginSheetModalForWindow:[sender window] completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            NSArray *selectedObjects = self.subtexturesController.selectedObjects;
            Subtexture *tex = [selectedObjects objectAtIndex:0];
            [tex.image setName:nil];
            
            
            NSString *path = [[panel URL] path];
            NSImage *newImage = [[NSImage alloc] initWithContentsOfFile:path];
            NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
            if (![newImage setName:name]) {
                [newImage setName:[NSString stringWithFormat:@"%@-1", name]];
            }
            
            tex.image = newImage;
            [self.textureView setNeedsDisplay:YES];
        }
    }];
    
}

- (BOOL)canModifySubtexture {
    return self.subtexturesController.selectedObjects.count==1;
}


- (IBAction)exportAtlas:(id)sender {

    
	// save image
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setAllowedFileTypes:[NSArray arrayWithObject:@"spatlas"]];
	[panel setNameFieldStringValue:[[self.displayName stringByDeletingPathExtension] stringByAppendingPathExtension:@"spatlas"]];
	[panel setCanCreateDirectories:YES];
	[panel setCanSelectHiddenExtension:YES];
	[panel setTitle:@"Save texture as Atlas File"];
    
    [panel beginSheetModalForWindow:[[self.windowControllers objectAtIndex:0] window] completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            
            // draw into NSImage;
            NSImage                 *outImage;
            NSBitmapImageRep        *rawImage;
            NSData                  *imageData;
            
            NSSize                  size = NSZeroSize;
            NSMutableData           *saveData;
            CGFloat                 scale;
            NSRect                  drawFrame;
            
            SPTextureAtlasHeader    header;
            SPTexAtlasMapCoords     *coords;
            
            header.atlasTag = kSPTextureAtlasTag;
            header.nMaps = self.textureView.subtextures.count;
            
            switch (_exportScale) {
                case 1: scale = 0.50; break;
                case 2: scale = 0.25; break;
                default:scale = 1.00; break;
            }
            
            coords = (SPTexAtlasMapCoords*)malloc(sizeof(SPTexAtlasMapCoords)*header.nMaps);
            
            int i=0;
            for (Subtexture *tex in self.textureView.subtextures) {
                NSRect frame = tex.frame;
                coords[i].x = tex.position.x*scale;
                coords[i].y = tex.position.y*scale;
                coords[i].w = frame.size.width*scale;
                coords[i].h = frame.size.height*scale;
                
                size.width = MAX(size.width, coords[i].x+coords[i].w);
                size.height = MAX(size.height, coords[i].y+coords[i].h);
                ++i;
            }

            outImage = [[NSImage alloc] initWithSize:size];
            
            [outImage lockFocus];
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
            i=0;
            for (Subtexture *tex in self.textureView.subtextures) {
                drawFrame = NSMakeRect(coords[i].x, coords[i].y, coords[i].w, coords[i].h);
                [tex.image drawInRect:drawFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
                ++i;
            }
            [outImage unlockFocus];
            
            rawImage =  [NSBitmapImageRep imageRepWithData:[outImage TIFFRepresentation]];
            imageData = [rawImage representationUsingType:NSPNGFileType properties:nil];
            
            header.pngLength = [imageData length];
            
            saveData = [NSMutableData dataWithCapacity:sizeof(SPTextureAtlasHeader)+sizeof(SPTexAtlasMapCoords)*header.nMaps+header.pngLength];
            [saveData appendBytes:&header length:sizeof(SPTextureAtlasHeader)];
            [saveData appendBytes:coords length:sizeof(SPTexAtlasMapCoords)*header.nMaps];
            [saveData appendData:imageData];
            
            free(coords);
            
            if ([saveData writeToURL:[panel URL] atomically:YES])
                NSLog(@"successful save of Atlas File");
            else {
                NSBeep();
                NSLog(@"unsuccessful save of Atlas File");
            }
        }
    }];
	
	      
}

- (IBAction)refactor:(id)sender {
    [self.textureView.subtextures makeObjectsPerformSelector:@selector(refactor)];
}

@end
