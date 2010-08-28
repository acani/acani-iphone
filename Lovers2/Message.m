#import "Message.h"

@implementation Message 

@dynamic timestamp;
@dynamic channel;
@dynamic sender;
@dynamic text;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
		[self setTimestamp:[dictionary valueForKey:@"timestamp"]];
		[self setChannel:[dictionary valueForKey:@"channel"]];
		[self setSender:[dictionary valueForKey:@"sender"]];
		[self setText:[dictionary valueForKey:@"text"]];
    }
    return self;
}

@end

//// Is dealloc necessary for CoreData entities?
//- (void)dealloc {
//    [sender release];
//    [channel release];
//    [timestamp release];
//    [text release];
//	// how do we dealloc timestamp (time_t)?
//	[super dealloc];
//}
//
