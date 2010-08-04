#import "User.h"
#import "SBJSON.h"
#import "JSON.h"

@implementation User

@synthesize uid;
@synthesize fbid;
@synthesize name;

- (id)initWithJsonDictionary:(NSDictionary*)dictionary {
	if (self = [super init]) {    
		self.uid       = [[dictionary objectForKey:@"_id"] objectForKey:@"$oid"];
		self.fbid      = [[dictionary objectForKey:@"fbid"] longValue];
		NSLog(@"user fbID %d", self.fbid);
		self.name      = [dictionary objectForKey:@"name"];
		NSLog(@"user fbID %@", self.name);
	}
	return self;
}
/*
+ (NSArray *)findNearest {
    NSURL *url = [NSURL URLWithString:@"file:///Users/Abhinav/code/ALphotoviewer/ALThumbs3/users.js"];
    
    NSError *error = nil;
    
    NSString *jsonString = 
	[NSString stringWithContentsOfURL:url 
							 encoding:NSUTF8StringEncoding 
								error:&error];
    
    NSMutableArray *users = [NSMutableArray array];
    if (jsonString) {
        SBJSON *json = [[SBJSON alloc] init];    
        NSArray *results = [json objectWithString:jsonString error:&error];
        [json release];
        
        for (NSDictionary *dictionary in results) {
            User *user = [[User alloc] initWithDictionary:dictionary];
            [users addObject:user];
            [user release];
        }
    }
    return users;    
}

*/ 

- (void)dealloc {
	[uid release];
	[name release];
   	[super dealloc];
}
 
@end
