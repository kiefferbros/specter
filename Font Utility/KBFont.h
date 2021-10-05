//
//  KBFont.h
//  Font Utility
//
//  Created by Jonathan Kieffer on 1/8/13.
//
//

#ifndef Font_Utility_KBFont_h
#define Font_Utility_KBFont_h

#if TARGET_OS_IPHONE
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#else
#import <OpenGL/gl.h>
#endif

typedef GLfloat KBFloat;

typedef union _KBVec2 {
    struct { KBFloat x, y; };
    struct { KBFloat w, h; };
    struct { KBFloat s, t; };
    KBFloat v[2];
} KBVec2;

typedef union KBBox {
    struct { KBFloat l, b, r, t; };
    struct { KBFloat x, y, w, h; };
} KBBox;

typedef struct _KBFontChar {
	char        character;
	KBBox       t;                  /* texture coords */
    KBVec2      s;                   /* in points */
	KBFloat     offsetY;			/* in points */
} KBFontChar;

typedef struct  {
    int         nCharacters;
	KBFloat     spaceWidth;
	KBFloat     tabWidth;
	KBFloat     tracking;
	KBFloat     leading;	
} KBFontHeader;

#endif
