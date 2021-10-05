//
//  AppController.m
//  Texture Packager
//
//  Created by Jonathan on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "ImageInfo.h"

NSString *kPhoneLoResKey = @"phonelo";
NSString *kPhoneHiResKey = @"phonehi";
NSString *kPadLoResKey = @"padlo";
NSString *kPadHiResKey = @"padhi";

@implementation AppController
@synthesize imageFolder, imageInfos;


@synthesize arrCntrl;
@synthesize wField, hField, aField;
@synthesize imageView;

- (void)awakeFromNib {
    previewIndex = 1;
	[self.arrCntrl addObserver:self forKeyPath:@"selection" options:0 context:NULL];
	[self addObserver:self forKeyPath:@"previewIndex" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)dealloc {
	[self.arrCntrl removeObserver:self forKeyPath:@"selection"];
}

- (ImageInfo*)imageInfoWithName:(NSString*)name inArray:(NSArray*)infoArray {
	for (ImageInfo *info in infoArray) {
		if ([info.name isEqualToString:name])
			return info;
	}
	
	return nil;
}

- (IBAction)showImageFolderPanel:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setTitle:@"Set Image Folder"];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setCanCreateDirectories:NO];
	
	if ([panel runModal] == NSFileHandlingPanelOKButton) {
		NSString *path = [[panel URL] path];
		self.imageFolder = [path stringByAbbreviatingWithTildeInPath];
		
		NSFileManager *fm = [NSFileManager defaultManager];
		
		NSArray *contents = [fm contentsOfDirectoryAtPath:path error:NULL];
		NSMutableArray *infos = [NSMutableArray arrayWithCapacity:10];
		
		for (NSString *file in contents) {
			if ([[file pathExtension] isEqualToString:@"png"] || [[file pathExtension] isEqualToString:@"spatlas"]) {
				NSString *fileName = [file stringByDeletingPathExtension];
				NSArray *comps = [fileName componentsSeparatedByString:@"-"];
				NSString *ident = [comps lastObject];
				if (comps.count > 1 && 
					([ident isEqualToString:kPhoneLoResKey] || 
					 [ident isEqualToString:kPhoneHiResKey] || 
					 [ident isEqualToString:kPadLoResKey] || 
					 [ident isEqualToString:kPadHiResKey])) 
				{
					NSArray *nameComps = [comps subarrayWithRange:NSMakeRange(0, comps.count-1)];
					NSString *name = [nameComps componentsJoinedByString:@"-"];
					
					ImageInfo *info = [self imageInfoWithName:name inArray:infos];
					if (!info) {
						info = [[ImageInfo alloc] initWithName:name];
						[infos addObject:info];
					}
					
					NSString *imagePath = [path stringByAppendingPathComponent:file];
					
					if ([ident isEqualToString:kPhoneLoResKey]) {
						[info loadImage:InfoImagePhoneLo atPath:imagePath];
					} else if ([ident isEqualToString:kPhoneHiResKey]) {
						[info loadImage:InfoImagePhoneHi atPath:imagePath];
					} else if ([ident isEqualToString:kPadLoResKey]) {
						[info loadImage:InfoImagePadLo atPath:imagePath];
					} else if ([ident isEqualToString:kPadHiResKey]) {
						[info loadImage:InfoImagePadHi atPath:imagePath];
					}
				}
			}
		}
		
		if (infos.count)
			self.imageInfos = infos;

	}
}


- (IBAction)loadTest:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setTitle:@"Set Image Folder"];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setCanCreateDirectories:NO];
	
	if ([panel runModal] == NSFileHandlingPanelOKButton) {
		NSString *path = [[panel URL] path];
		SPTexturePack *pack = [[SPTexturePack alloc] initWithContentsOfFile:path preload:NO retain:NO];
        
        NSLog(@"%@", pack.names);
	}
}

- (IBAction)export:(id)sender {
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setTitle:@"Export Texture Package"];
	[panel setCanCreateDirectories:YES];
	[panel setCanSelectHiddenExtension:YES];
	[panel setAllowedFileTypes:[NSArray arrayWithObject:@"sptex"]];
	[panel setNameFieldStringValue:@"Untitled Texture Package.sptex"];
	
	
	if ([panel runModal] == NSFileHandlingPanelOKButton) {
        
        NSMutableDictionary *wrappers = [NSMutableDictionary dictionary];
		
		NSMutableData *headerData = [NSMutableData data];
        uint32_t fileTag = kSPTexturePackFileTag;
        [headerData appendBytes:&fileTag length:sizeof(uint32_t)];
		unsigned int nTextures = [imageInfos count];
		
		[headerData appendBytes:&nTextures length:sizeof(unsigned int)];

        NSUInteger index = 0;
		for (ImageInfo *info in imageInfos) {
			// append to header data
			const char *name = [info.name UTF8String];
			
			NSString *phoneHi = ([info image:InfoImagePhoneHi]) ? [NSString stringWithFormat:@"%lu-%@", index, kPhoneHiResKey] : nil;
			NSString *phoneLo = ([info image:InfoImagePhoneLo]||[info image:InfoImagePhoneHi]) ? [NSString stringWithFormat:@"%lu-%@", index, kPhoneLoResKey] : nil;
			NSString *padHi = ([info image:InfoImagePadHi]) ? [NSString stringWithFormat:@"%lu-%@", index, kPadHiResKey] : nil;
			NSString *padLo =  ([info image:InfoImagePadLo]||[info image:InfoImagePadHi]) ? [NSString stringWithFormat:@"%lu-%@", index, kPadLoResKey] : nil;
			
			
			const char *phoneLoFile = (phoneLo != nil) ? [phoneLo UTF8String] : "\0";
			const char *phoneHiFile = (phoneHi != nil) ? [phoneHi UTF8String] : "\0";
			const char *padLoFile = (padLo != nil) ? [padLo UTF8String] : "\0";
			const char *padHiFile = (padHi != nil) ? [padHi UTF8String] : "\0";
			
			[headerData appendBytes:name length:strlen(name)+1];
			[headerData appendBytes:phoneLoFile length:strlen(phoneLoFile)+1];
			[headerData appendBytes:phoneHiFile length:strlen(phoneHiFile)+1];
			[headerData appendBytes:padLoFile length:strlen(padLoFile)+1];
            [headerData appendBytes:padHiFile length:strlen(padHiFile)+1];
			
            
            [wrappers setObject:[[NSFileWrapper alloc] initRegularFileWithContents:headerData] forKey:@"info"];
			
			// create image files
			NSData *phoneHiData = [info imageData:InfoImagePhoneHi];
			if (phoneHiData) {
                [wrappers setObject:[[NSFileWrapper alloc] initRegularFileWithContents:phoneHiData] forKey:phoneHi];
			}
			
			NSData *phoneLoData = [info imageData:InfoImagePhoneLo];
			if (phoneLoData) {
                [wrappers setObject:[[NSFileWrapper alloc] initRegularFileWithContents:phoneLoData] forKey:phoneLo];
			}
					   
			NSData *padHiData = [info imageData:InfoImagePadHi];
			if (padHiData) {
                [wrappers setObject:[[NSFileWrapper alloc] initRegularFileWithContents:padHiData] forKey:padHi];
			}
            
            NSData *padLoData = [info imageData:InfoImagePadLo];
			if (padLoData) {
                [wrappers setObject:[[NSFileWrapper alloc] initRegularFileWithContents:padLoData] forKey:padLo];
			}
            index++;
		}
        
        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
        [wrapper writeToURL:[panel URL] options:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSImage *image = nil;
    ImageInfo *info = nil;
    NSArray *selectedObjects = [self.arrCntrl valueForKeyPath:@"selectedObjects"];
    if (selectedObjects.count) {
        info = [selectedObjects objectAtIndex:0];
        image = [info image:previewIndex];
    }
	
    if (![image isMemberOfClass:[NSImage class]]) 
        image = nil;
    
	[self.imageView setImage:image];
	if (image) {		
		[aField setStringValue:[info atlasData:previewIndex]!=nil ? @"YES" : @"NO"];
		[wField setStringValue:[NSString stringWithFormat:@"%i", (int)image.size.width]];
		[hField setStringValue:[NSString stringWithFormat:@"%i", (int)image.size.height]];		
	} else {
		[aField setStringValue:@""];
		[wField setStringValue:@""];
		[hField setStringValue:@""];
	}		
}
@end
