#import "CustomURLConnection.h"

@implementation CustomURLConnection

@synthesize tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag_t {
	self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
	if (self) {
		self.tag = tag_t;
	}
	return self;
}

- (void)dealloc {
	[tag release];
	[super dealloc];
}

@end
