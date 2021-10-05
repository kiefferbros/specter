//
//  KBLabel.h
//  Aqueduct Project
//
//  Created by Jonathan on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPLabel.h"

@class KBFont;
@interface KBLabel : UIView {
@private
	SPFloat			_tracking;
	SPFloat			_leading;
	
	SPFloat		_width;
	NSUInteger _numberOfLines;
	
	NSString *_text;
	KBFont *_font;
}
@property(readonly) SPFloat width;
@property(readonly) NSUInteger numberOfLines;
@property (nonatomic, assign) SPFloat tracking;
@property (nonatomic, assign) SPFloat leading;
@property(nonatomic) NSString *text;
@property(nonatomic) KBFont *font;
@end

@interface KBFont : NSObject
{
	CGImageRef	_image;
	NSUInteger	_numberOfCharacters;
	SPCharInfo	*_charInfo;
	SPFloat		_spaceWidth, _tabWidth, _tracking, _leading, _scale;
}
@property(nonatomic, readonly) CGImageRef image;
@property(readonly) SPCharInfo *charInfo;
@property(readonly) SPFloat spaceWidth, tabWidth, defaultTracking, defaultLeading, scale;
+ (KBFont*)fontNamed:(NSString*)name;		
- (id)initWithContentsOfFile:(NSString*)filePath;
- (id)initWithData:(NSData*)data;
- (SPCharInfo*)infoForCharacter:(unichar)character;
@end