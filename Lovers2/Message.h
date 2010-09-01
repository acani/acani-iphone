#import <CoreData/CoreData.h>

@interface Message : NSManagedObject {
}

@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSString * text;

@end

//MessageOld.h
//
//@interface Message : NSObject {
//	NSString *sender;
//	NSString *channel; // uid1_uid2
//	time_t timestamp;
//	NSString *text;
//}
//
//- (id)initWithDictionary:(NSDictionary *)dictionary;
//
//@end