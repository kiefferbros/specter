//
//  NumberLabel.m
//  Redtail
//
//  Created by Jonathan on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SPLabel.h"
#import "Specter.h"

@interface SPLabel () 
- (void)updateText;
- (SPFloat)widthOfLine:(NSUInteger)lineIndex withFontScale:(SPFloat)scale;
- (SPFloat)widthOfCharacter:(unichar)character withFontScale:(SPFloat)scale;
- (SPFloat)initialXForWidth:(SPFloat)width;
- (void)updateIndexBuffer;
@end

@implementation SPLabel

- (id)initWithText:(NSString*)text font:(SPFont*)font alignment:(SPTextAlignment)alignment {
	if ((self=[super initWithTexture:nil])) {
		_font = font;
		
		_tracking = font.defaultTracking;
		_leading = font.defaultLeading;
		_alignment = alignment;
        
        _elementBuffer = [[SPElementBuffer alloc] init];
		
		self.text = text;
	}
	return self;
}



- (void)setFont:(SPFont*)font {
	_font = font;
	
	_leading = _font.defaultLeading;
	_tracking = _font.defaultTracking;
	
	[self updateText];
}

- (SPFont*)font {
	return _font;
}

- (void)setText:(NSString*)text {
	_text = text;
    
    _lines = [_text componentsSeparatedByString:@"\n"];
    
    //get the number drawable characters
	_charCount=0;
	for (int i=0; i<[_text length]; ++i) {
		unichar c = [_text characterAtIndex:i];
		if ([_font infoForCharacter:c] != NULL)
			++_charCount;
	}
    
	[self updateText];
}

- (NSString*)text  {
	return _text;
}

- (NSString*)text:(NSString*)text withBreaksForWidth:(SPFloat)width {
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    
    NSMutableArray *newLines = [NSMutableArray arrayWithCapacity:lines.count];
    BOOL modified = NO;
    
    SPFloat fS = _font.texture.scale;
    
    for (NSString *line in lines) {
        NSArray *words = [line componentsSeparatedByString:@" "];
        BOOL lineBroken = NO;
        SPFloat lineW = 0.f;
        if (words.count > 1) {
            // line has enough words to break up
            int j=0, k=0;
            for (NSString *word in words) {
                
                // find the width of the word
                SPFloat wordW = 0.f;
                SPFloat spaceW = [self widthOfCharacter:' ' withFontScale:fS];
                if (j>0) {
                    wordW += spaceW;
                }
                for (int i=0; i<word.length; ++i) {
                    wordW += [self widthOfCharacter:[word characterAtIndex:i] withFontScale:fS];
                }
                
                BOOL lastWord = j==words.count-1;
                BOOL greaterWidth = lineW+wordW > width;
                if (greaterWidth || (lineBroken && lastWord)) { 
                    NSUInteger rangeLen = !greaterWidth && lastWord ? words.count-k : j-k;
                    
                    NSArray *subWords = [words subarrayWithRange:NSMakeRange(k, rangeLen)];
                    NSString *newLine = [subWords componentsJoinedByString:@" "];
                    [newLines addObject:newLine];
                
                    if (greaterWidth && lastWord) 
                        [newLines addObject:word];
                    
                    k=j;
                    lineW = wordW - spaceW;
                    lineBroken = YES;
                    
                } else {
                    lineW += wordW;
                }
                ++j;
            }
        }
        
        if (lineBroken) {
            modified  = YES;
        } else {
            [newLines addObject:line];
        } 
    }

    return modified ? [newLines componentsJoinedByString:@"\n"] : text;
}

- (void)containTextToWidth:(SPFloat)width {
    self.text = [self text:self.text withBreaksForWidth:width];
}

- (void)setTracking:(SPFloat)aFloat {
	_tracking = aFloat;
	[self updateText];
}

- (SPFloat)tracking {
	return _tracking;
}

- (void)setLeading:(SPFloat)leading {
	_leading = leading;
	[self updateText];
}

- (SPFloat)leading {
	return _leading;
}

- (void)setAlignment:(SPTextAlignment)align {
	_alignment = align;
	[self updateText];
}

- (SPTextAlignment)alignment {
	return _alignment;
}

-(NSUInteger)numberOfLines {
    return _lines.count;
}

- (SPFloat)widthOfCharacter:(unichar)character withFontScale:(SPFloat)scale {
    SPFloat w = 0.f;
    
    if (character == ' ') {
        w = _font.spaceWidth + _tracking;
    } else if (character == '\t') {
        w = _font.tabWidth + _tracking;
    } else {
        SPCharInfo *info = [_font infoForCharacter:character];				
        if (info) {
            w = (info->width/scale)+info->frontPad+info->backPad+_tracking;;
        } else {
            w = _font.spaceWidth + _tracking;
        }
    }
    
    return w;
}

- (SPFloat)widthOfLine:(NSUInteger)lineIndex withFontScale:(SPFloat)scale  {
	if (lineIndex < _lines.count) {
		NSString *line = [_lines objectAtIndex:lineIndex];
		
		SPFloat w = 0.f;
		for (int i=0; i<[line length]; ++i) {
			unichar character = [line characterAtIndex:i];
			w += [self widthOfCharacter:character withFontScale:scale];			
		}

		w -= _tracking;
		return w;
	}
	return 0.f;
}

- (SPFloat)initialXForWidth:(SPFloat)width {
	SPFloat x;
	
	switch (_alignment) {
		case SPTextAlignmentCenter:
			x = roundf(-width*.5f);
			break;
		case SPTextAlignmentRight:
			x = -width;
			break;
		default:
			x = 0.f;
			break;
	}
	
	return x;
}

- (void)willChangeScene {
    
}

- (void)didChangeScene {
    [self updateIndexBuffer];
}

- (void)updateIndexBuffer {
    if (_charCount > _elementBuffer.count)
        _elementBuffer.count = _charCount;
}

- (void)updateText {
	_contentBox = SPBoxZero;

	if (_charCount) {
		// update the sprite index buffer
        [self updateIndexBuffer];
        
        // bind the vertex buffer object and ready it for writing
        glBindBuffer(GL_ARRAY_BUFFER, _vbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(SPVertex)*_charCount*4, NULL, GL_STATIC_DRAW);
#if TARGET_OS_IPHONE
        SPVertex *vt = (SPVertex*)glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
#else
        SPVertex *vt = (SPVertex*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
#endif
		
        // initialize variables
		SPFloat x, y, tS, tW, tH, lineW;
        y = 0.f;
        tS = _font.texture.scale;
        tW = _font.texture.glWidth;
        tH = _font.texture.glHeight;
		
        // loop through each line
        int j=0;
        for (NSString *line in _lines) {
            
            lineW = [self widthOfLine:j withFontScale:tS];
            x = [self initialXForWidth:lineW];
            
            // expand content box if necessary
            _contentBox.l = SPFloatMin(_contentBox.l, x);
            _contentBox.r = SPFloatMax(_contentBox.r, x+lineW);
            
            // loop through each character
            for (int i=0; i<[line length]; ++i) {
                unichar character = [line characterAtIndex:i];

                SPCharInfo *info = [_font infoForCharacter:character];				
                if (info != NULL) {
                    // update the vertex data to draw the character

                    vt[0].p.x = vt[1].p.x = x+info->frontPad; 
					vt[2].p.x = vt[3].p.x = x+(info->width/tS)+info->frontPad; 
                    
                    SPFloat b, t;
                    b = y+info->offsetY;
                    t = y+(info->height/tS)+info->offsetY;
					
					vt[0].p.y = vt[2].p.y = b;
					vt[1].p.y = vt[3].p.y = t;
					
					vt[0].t.x = vt[1].t.x = info->x/tW;					// minS
                    vt[2].t.x = vt[3].t.x = (info->x+info->width)/tW;		// maxS	
					vt[0].t.y = vt[2].t.y = info->y/tH;					// min
					vt[1].t.y = vt[3].t.y = (info->y+info->height)/tH;	// maxT
					
					
					_contentBox.b = SPFloatMin(_contentBox.b, b);
					_contentBox.t = SPFloatMax(_contentBox.t, t);
                    
                    vt += 4;
                }
                x += [self widthOfCharacter:character withFontScale:tS];
            }
            
            y -= _leading;
            ++j;
        }
#if TARGET_OS_IPHONE        
        glUnmapBufferOES(GL_ARRAY_BUFFER);
#else
        glUnmapBuffer(GL_ARRAY_BUFFER);
#endif
        glBindBuffer(GL_ARRAY_BUFFER, 0);

	}
}

- (void)draw {
	if (_charCount) {
		[self makeColorCurrent];
		
		glBindTexture(GL_TEXTURE_2D, _font.texture.glName);
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _elementBuffer.glName);
        
		glVertexPointer(2, GL_FLOAT, sizeof(SPVertex), 0);
		glTexCoordPointer(2, GL_FLOAT, sizeof(SPVertex), (GLvoid*)(sizeof(GLfloat)*2));
		

        glDrawElements(GL_TRIANGLE_STRIP, _charCount*6, GL_UNSIGNED_SHORT, 0);
		
		glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	}
}

- (SPBox)contentBox {
	return _contentBox;
}
@end

@implementation SPFont
@synthesize texture=_texture;
@synthesize spaceWidth = _spaceWidth;
@synthesize tabWidth = _tabWidth;
@synthesize defaultTracking = _tracking;
@synthesize defaultLeading = _leading;

+ (SPFont*)fontNamed:(NSString *)name {	
	if (![[name pathExtension] length])
		name = [name stringByAppendingPathExtension:@"spfont"];
	
	//SPFont *font = [[_SPFontManager defaultManager] cachedFontWithName:[SPTexture hiResNameForName:name]];
	//if (!font) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *path = [bundle pathForResource:name ofType:nil];
		SPFloat ss, ts;
		path = [SPTexture hiResPathForPath:path screenScale:&ss textureScale:&ts];
		
		
		SPFont *font = [[SPFont alloc] initWithContentsOfFile:path];
		//[[_SPFontManager defaultManager] cacheFont:font withName:[path lastPathComponent]];
	//}
	
	return font;	
}

- (id)initWithContentsOfFile:(NSString*)filePath {
	SPFloat ss, ts;
	filePath = [SPTexture hiResPathForPath:filePath screenScale:&ss textureScale:&ts];
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	return [self initWithData:data];
}

- (id)initWithData:(NSData*)data {
	if ((self=[super init])) {
		// read the header
		SPFontHeader header;
		
		NSRange readRange = NSMakeRange(0, sizeof(header));
		
		[data getBytes:&header range:readRange];
		readRange.location += readRange.length;
		
		// update instance variables
		_spaceWidth = header.spaceWidth;
		_tabWidth = header.tabWidth;
		_tracking = header.tracking;
		_leading = header.leading;
		_numberOfCharacters = header.nCharacters;
		
		// create character info
		readRange.length = sizeof(SPCharInfo)*_numberOfCharacters;
		_charInfo = (SPCharInfo*)malloc(readRange.length);
		
		[data getBytes:_charInfo range:readRange];
		readRange.location += readRange.length;
		readRange.length = header.textureDataLength;
		
		
		NSData *textureData = [data subdataWithRange:readRange];
		
		CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)textureData);
		CGImageRef image = CGImageCreateWithPNGDataProvider(provider, NULL, FALSE, kCGRenderingIntentDefault);
		CGDataProviderRelease(provider);
		
		_texture = [[SPTexture alloc] initWithImage:image scale:header.scale options:SPTextureOptionsDefault];
		CGImageRelease(image);
	}
	return self;
}

- (void)dealloc {
	free(_charInfo);
}


- (SPCharInfo *)charInfo {
	return _charInfo;
}

- (SPCharInfo *)infoForCharacter:(unichar)character {
	for (int i=0; i<_numberOfCharacters; ++i) {
		if (_charInfo[i].character == character) {
			return &_charInfo[i];
		}
	}
	
	return NULL;
}
@end


@implementation SPElementBuffer
@synthesize glName=_glName;

- (id)init {
    if ((self = [super init])) {
        glGenBuffers(1, &_glName);        
    }
    return self;
}

- (void)dealloc {
    glDeleteBuffers(1, &_glName);
}


- (NSUInteger)count {
    return _count;
}

- (void)setCount:(NSUInteger)count {    
    if (count != _count) {
        _count = count;
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _glName);
		
		GLushort idxs[count*6];
		
		GLushort j = 0;
		for (int i=0; i<count; ++i) {
			idxs[i*6] = idxs[i*6+1] = j;
			idxs[i*6+2] = j+1;
			idxs[i*6+3] = j+2;
			idxs[i*6+4] = idxs[i*6+5] = j+3;
			
			j += 4;
		}
		
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(idxs), idxs, GL_STATIC_DRAW);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
}

- (void)bind {
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.glName);
}

- (void)unbind {
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

@end
