//
//  SPGradient.h
//  MonsterSoup
//
//  Created by Jonathan on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTypes.h"

@interface SPGradient : NSObject {
@private
	SPFloat *_color;
	SPFloat	*_location;
}
@property (nonatomic, readonly) NSUInteger stopCount;
@property (nonatomic, readonly) NSUInteger componentCount;
- (id)initWithColors:(SPFloat*)colors locations:(SPFloat*)locations componentCount:(NSUInteger)nComps stopCount:(NSUInteger)nStops;
- (void)getColor:(out SPFloat*)color atLocation:(SPFloat)delta;
@end
