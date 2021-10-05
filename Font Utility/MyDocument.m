//
//  MyDocument.m
//  Font Utility
//
//  Created by Jonathan on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "BitmapCharacter.h"
#import "GLView.h"
#import "ImageView.h"

#import "KBFont.h"

@implementation MyDocument
@synthesize selectedCharacter;
@synthesize spaceWidth;
@synthesize tabWidth;
@synthesize previewInfo;
@synthesize hiResTexture;
@synthesize padTexture;
@synthesize autocrop;
- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		// ASCII characters
		characters = [[NSArray alloc] initWithObjects:@"!", @"\"", @"#", @"$", @"%", @"&", @"'", @"(", @")", 
					  @"*", @"+", @",", @"-", @".", @"/", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", 
					  @"9", @":", @";", @"<", @"=", @">", @"?", @"@", @"A", @"B", @"C", @"D", @"E", @"F", @"G", 
					  @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", 
					  @"W", @"X", @"Y", @"Z", @"[", @"\\", @"]", @"^", @"_", @"`", @"a", @"b", @"c", @"d", @"e", 
					  @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", 
					  @"u", @"v", @"w", @"x", @"y", @"z", @"{", @"|", @"}", @"~", @"€", @"¥", @"£", nil];
		
		bitmapCharacters = [[NSMutableDictionary alloc] initWithCapacity:[characters count]];
		
		previewInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
		[previewInfo setObject:[NSNumber numberWithFloat:0.0] forKey:@"tracking"];
		[previewInfo setObject:[NSNumber numberWithFloat:12.0] forKey:@"leading"];
		[previewInfo setObject:[NSNumber numberWithFloat:1.0] forKey:@"scale"];
		[previewInfo setObject:[NSNumber numberWithBool:YES] forKey:@"hiRes"];
		[previewInfo setObject:@"!\"#$%&'()*+,-./0123456789\n:;<=>?@ABCDEFGHIJKLM\nNOPQRSTUVWXYZ[\\]^_`\nabcdefghijklmnopqrstuvwx\nyz{|}~" forKey:@"text"];
		[previewInfo setObject:[NSNumber numberWithUnsignedInteger:SPTextAlignmentLeft] forKey:@"alignment"];
		
		hiResTexture = YES;
		padTexture = YES;
        autocrop = YES;
        size = 12.f;
    }
    return self;
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
	
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

	
	
	
	//if ( outError != NULL ) {
	//	*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	//	return nil;
	//}
	
	NSDictionary *docDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								   bitmapCharacters, @"characters", 
								   [NSNumber numberWithFloat:spaceWidth], @"spaceWidth",
								   [NSNumber numberWithFloat:tabWidth], @"tabWidth",
								   [NSNumber numberWithFloat:defaultTracking], @"defaultTracking",
								   [NSNumber numberWithFloat:defaultLeading], @"defaultLeading",
								   [NSNumber numberWithBool:hiResTexture], @"hiResTexture",
								   [NSNumber numberWithBool:padTexture], @"padTexture",
                                   [NSNumber numberWithBool:autocrop], @"autocrop",
								   previewInfo, @"previewInfo",
								   nil];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:docDictionary];	
	
	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	
	
	NSDictionary *docDictionary = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	bitmapCharacters = [docDictionary objectForKey:@"characters"];
	
	previewInfo = [docDictionary objectForKey:@"previewInfo"];
	
	spaceWidth = [[docDictionary objectForKey:@"spaceWidth"] floatValue];
	tabWidth = [[docDictionary objectForKey:@"tabWidth"] floatValue];
	defaultTracking = [[docDictionary objectForKey:@"defaultTracking"] floatValue];
	defaultLeading = [[docDictionary objectForKey:@"defaultLeading"] floatValue];
	hiResTexture = [[docDictionary objectForKey:@"hiResTexture"] boolValue];
	padTexture = [[docDictionary objectForKey:@"padTexture"] boolValue];
    autocrop = [[docDictionary objectForKey:@"autocrop"] boolValue];

    return YES;
}

- (void)glViewDidPrepare:(GLView*)glView {
	[self buildPreviewFont:nil];
}

#pragma mark -
#pragma mark NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [characters count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if ([[aTableColumn identifier] isEqualToString:@"ascii"]) {
		return [characters objectAtIndex:rowIndex];
	}
	else if ([[aTableColumn identifier] isEqualToString:@"bitmap"]) {
		return [[bitmapCharacters objectForKey:[characters objectAtIndex:rowIndex]] image];
	}
	
	return nil;
}

- (NSImage*)tableViewWillCopyImage:(NSTableView*)aTableView {
	NSInteger selectedRow = [aTableView selectedRow];
	BitmapCharacter *character = [bitmapCharacters objectForKey:[characters objectAtIndex:selectedRow]];
	return [character image];
}

- (void)tableView:(NSTableView*)aTableView didPasteImage:(NSImage*)image {
	NSInteger selectedRow = [aTableView selectedRow];
	
	BitmapCharacter *character = [[BitmapCharacter alloc] initWithBitmapImage:image crop:autocrop];
    if (character) {
        [bitmapCharacters setObject:character forKey:[characters objectAtIndex:selectedRow]];
        
        self.selectedCharacter = character;
        
        [aTableView reloadData];
        [self buildPreviewFont:nil];
    }
	
}

- (void)tableViewWillDelete:(NSTableView*)aTableView {
	NSInteger selectedRow = [aTableView selectedRow];
	[bitmapCharacters removeObjectForKey:[characters objectAtIndex:selectedRow]];
	[aTableView reloadData];
	[self buildPreviewFont:nil];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	NSString *asciiChar = [characters objectAtIndex:row];
	if (asciiChar) {
		BitmapCharacter *character = [bitmapCharacters objectForKey:asciiChar];
		if (character) {
			return SPFloatMax(18.0, [character height]);
		}
	}
	
	return 18.0;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
	self.selectedCharacter = [bitmapCharacters objectForKey:[characters objectAtIndex:rowIndex]];
	return YES;
}

#pragma mark -
#pragma mark Preview
- (IBAction)updatePreview:(id)sender {
	if (![bitmapCharacters count]) return;
	
	if (!previewView.label.font) {
		SPFont *font = [[SPFont alloc] initWithData:[self fontData:hiResTexture showPreview:YES compress:NO]];
		previewView.label.font = font;	
	}
	
	previewView.label.text = [previewInfo objectForKey:@"text"];
	previewView.label.leading = [[previewInfo objectForKey:@"leading"] floatValue];
	previewView.label.tracking = [[previewInfo objectForKey:@"tracking"] floatValue];
	previewView.label.alignment = [[previewInfo objectForKey:@"alignment"] unsignedIntegerValue];
	
	switch (previewView.label.alignment) {
		case SPTextAlignmentLeft:
			previewView.label.tx = 0.f;
			break;
		case SPTextAlignmentCenter:
			previewView.label.tx = previewView.bounds.size.width/2.f;
			break;
		case SPTextAlignmentRight:
			previewView.label.tx = previewView.bounds.size.width;
			break;	
	}
	
	SPFloat scale = [[previewInfo objectForKey:@"scale"] floatValue];
	previewView.label.scale = SPVec2Make(scale, scale);
	[previewView drawScene];
}

- (IBAction)buildPreviewFont:(id)sender {
	if (![bitmapCharacters count]) {
		previewView.label.font = nil;
		textureView.image = nil;
        [dimensionField setStringValue:@"0x0"];
		[previewView drawScene];
		return;
	}
	
	SPFont *font = [[SPFont alloc] initWithData:[self fontData:[[previewInfo objectForKey:@"hiRes"] boolValue] showPreview:YES compress:NO]];
	
	previewView.label.font = font;	
	[self updatePreview:nil];
	 
}

- (IBAction)syncTracking:(id)sender {
	[self setValue:[previewInfo objectForKey:@"tracking"] forKey:@"defaultTracking"];
}

- (IBAction)syncLeading:(id)sender {
	[self setValue:[previewInfo objectForKey:@"leading"] forKey:@"defaultLeading"];
}

#pragma mark -
#pragma mark Build Font
- (NSData*)fontData:(BOOL)hiRes showPreview:(BOOL)showPreview compress:(BOOL)compress  {
	SPFontHeader header;
	
	header.spaceWidth =  spaceWidth;
	header.tabWidth = tabWidth;
	header.tracking = defaultTracking;
	header.leading = defaultLeading;
	header.scale = (hiRes) ? 2.f : 1.f;
	header.nCharacters = bitmapCharacters.count;
	
	NSUInteger w, h, charArea, pad;
	pad = hiResTexture ? 2 : 1;
	
	// find the total area the character take up in pixels^2
	charArea = 0;
	for (NSString *string in characters) {
		BitmapCharacter *character = [bitmapCharacters objectForKey:string];
		if (character) {
			if (padTexture)
				charArea += (character.width+pad)*(character.height+pad);
			else 
				charArea += character.width*character.height;
		}	
	}
	
	// just shoot for a square texture for now
	w = sqrt(charArea);
	// round up the width to a power of 2
	if((w != 1) && (w & (w - 1))) {
		NSUInteger i = 1;
		while(i < w) i *= 2;
		w = i;
	}
	
	CGFloat s = 1.f;
	if (!hiRes && hiResTexture)
		s = 0.5f;
	
	w *= s;
	
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[bitmapCharacters count]];
	SPCharInfo *charInfo = (SPCharInfo*)malloc(sizeof(SPCharInfo)*header.nCharacters);
    NSUInteger charOption = !hiResTexture ? kLoResCharForLoResTex : hiRes ? kHiResCharForHiResTex : kLoResCharForHiResTex;
	
	// figure out the height for a given width
	// while we're at it, build the character info array
	int j=0;
	SPFloat x=0, y=0, maxH=0;
	for (NSString *string in characters) {
		BitmapCharacter *character = [bitmapCharacters objectForKey:string];
		if (character) {
			unichar c = [string characterAtIndex:0];
			
			if (x+character.width*s>w) {
				// new line
				x = 0;
				y += maxH;
				maxH = 0;
			}

			
			SPCharInfo info = {c, x, y, 0., 0., character.frontPad, character.backPad, character.offsetY};
            NSImage *image = [character alignedImageWithCharInfo:&info option:charOption];
            
			charInfo[j] = info;
            [images addObject:image];
			
			x += info.width + (padTexture?pad:0);
			maxH = SPFloatMax(maxH, info.height + (padTexture?pad:0));
			++j;
		}
	}
	
	h = y + maxH;
	// round up the height to the nearest power of 2
	//if((h != 1) && (h & (h - 1))) {
	//	NSUInteger i = 1;
	//	while(i < h) i *= 2;
	//	h = i;
	//}
	
	if (!h || !w) {
		free(charInfo);
		return nil;
	}	
	
	// build the texture
	NSImage *texImg = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
	[texImg lockFocus];
	
	// draw character to image
	int i=0;
	for (NSImage *image in images) {
		
			SPCharInfo *info = &charInfo[i];
			[image drawInRect:NSMakeRect(info->x, info->y, info->width, info->height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
			++i;
		
	}
	
	[texImg unlockFocus];
	
	// show image in the texture preview view
	if (showPreview) {
		textureView.image = texImg;
        [dimensionField setStringValue:[NSString stringWithFormat:@"%lux%lu", w, h]];
	}
	
	// get the image data;
	NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[texImg TIFFRepresentation]];
	NSData *texData = [rep representationUsingType:NSPNGFileType properties:nil];
    
    if (compress) {
        // save image data to a temp file that can be compressed by optipng
        NSString *path = [@"~/Library/Application Support/Specter/Font Utility/tmp/" stringByExpandingTildeInPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:path]) {
            NSError *error = nil;
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (error != nil) {
                NSLog(@"Error creating Temp Directory: %@", error);
            }
        }
        
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [self displayName]]];
        [texData writeToFile:path atomically:YES];
        
        NSString *optiPath = [[NSBundle mainBundle] pathForResource:@"optipng" ofType:nil];
        NSString *command = [NSString stringWithFormat:@"\"%@\" -o7 \"%@\"", optiPath, path];
        
        // run the unix shell script
        system([command UTF8String]);
        
        // read the compressed file
        texData = [NSData dataWithContentsOfFile:path];
    }
    
    //
	header.textureDataLength = [texData length];
	
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&header length:sizeof(SPFontHeader)];
	[data appendBytes:charInfo length:sizeof(SPCharInfo)*header.nCharacters];
	
	[data appendData:texData];
	
	free(charInfo);	
	
	return data;
}
@end
