//
//  KBImagePack.h
//  MonsterSoup
//
//  Created by Jonathan Kieffer on 2/25/11.
//  Copyright 2011 Kieffer Bros., LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTexturePack.h"

@interface KBImagePack : NSObject {
@private
	unsigned int			_nImages;
	NSDictionary			*_fileNames;
	
	NSMutableDictionary		*_images;
	
	NSString				*_packPath;
	
	BOOL					_retainImages;
}
@property (nonatomic, readonly) NSArray *names;

- (id)initWithContentsOfFile:(NSString*)path preload:(BOOL)preload retain:(BOOL)retain;

- (UIImage*)imageNamed:(NSString*)name;

- (void)unloadImages;
@end
