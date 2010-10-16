#import "ThumbView.h"


@implementation ThumbView

@synthesize user;

- (void)dealloc {
	[user dealloc];
    [super dealloc];
}

@end
