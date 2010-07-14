#import <Foundation/Foundation.h>

@interface Message : NSObject {
	NSString* text;
	NSString* timestamp;
//	uint32_t sender_id;
//	uint32_t receiver_id;
}

@property (nonatomic, retain) NSString* text;
@property (nonatomic, assign) NSString* timestamp;
//@property (nonatomic, assign) uint32_t sender_id;
//@property (nonatomic, assign) uint32_t receiver_id;

@end
