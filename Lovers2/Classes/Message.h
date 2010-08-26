@interface Message : NSObject {
	NSString *channel; // uid1_uid2
	time_t timestamp;
	NSString *text;
}

@property (nonatomic, retain) NSString *channel;
@property (nonatomic, assign) time_t timestamp;
@property (nonatomic, retain) NSString *text;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
