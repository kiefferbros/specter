//
//  NumberLabel.h
//  Redtail
//
//  Created by Jonathan on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSprite.h"

typedef enum {
	SPTextAlignmentLeft = 0,
	SPTextAlignmentCenter,
	SPTextAlignmentRight
} SPTextAlignment;

typedef enum {
	SPTextVAligmentTop = 0,
	SPTextVAlignemntTopBaseline,
	SPTextVAligmentMiddle,
	SPTextVAligmentBottomBaseline,
	SPTextVAlignmentBottom
} SPTextVAlignemnt;

typedef struct  {
	unichar character;
	SPFloat x, y;				// in pixels
	SPFloat	width, height;		// in pixels
	SPFloat frontPad, backPad;  // in points
	SPFloat offsetY;			// in points
} SPCharInfo;

@class SPFont, SPElementBuffer;
@interface SPLabel : SPSprite {
@private
	SPFloat				_tracking, _leading;
	
	SPTextAlignment		_alignment;
	
	GLuint				_charCount;
	
	NSString			*_text;
    NSArray             *_lines;
    
    
	SPFont				*_font;
	
	SPBox				_contentBox;
    
    SPElementBuffer     *_elementBuffer;
}
@property(readonly) NSUInteger numberOfLines;
@property (nonatomic, assign) SPFloat tracking; 
@property (nonatomic, assign) SPFloat leading;
@property (nonatomic, assign) SPTextAlignment alignment;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) SPFont *font;
- (id)initWithText:(NSString*)text font:(SPFont*)font alignment:(SPTextAlignment)alignment;
- (NSString*)text:(NSString*)text withBreaksForWidth:(SPFloat)width;
- (void)containTextToWidth:(SPFloat)width;
@end

typedef struct  {
	SPFloat spaceWidth;
	SPFloat tabWidth;
	SPFloat tracking;
	SPFloat leading;
	SPFloat scale;
	uint32_t nCharacters;
	uint32_t textureDataLength;
} SPFontHeader;

@interface SPFont : NSObject
{
@package
	SPTexture	*_texture;
	NSUInteger	_numberOfCharacters;
	SPCharInfo	*_charInfo;
	SPFloat		_spaceWidth, _tabWidth, _tracking, _leading;
}
@property(nonatomic, readonly) SPTexture *texture;
@property(readonly) SPCharInfo *charInfo;
@property(readonly) SPFloat spaceWidth, tabWidth, defaultTracking, defaultLeading;
+ (SPFont*)fontNamed:(NSString*)name;		// caches font
- (id)initWithContentsOfFile:(NSString*)filePath;
- (id)initWithData:(NSData*)data;
- (SPCharInfo*)infoForCharacter:(unichar)character;
@end


@interface SPElementBuffer : NSObject {
@private
    GLuint _glName;
    NSUInteger _count;
}
@property (nonatomic, readonly) GLuint glName;
@property (nonatomic, assign) NSUInteger count; // number of quads that can be draw with element array buffer
- (void)bind;
- (void)unbind;
@end

