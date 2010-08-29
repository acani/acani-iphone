@interface User : NSObject {
	NSString *uid;
	uint32_t fbid;
	NSString *name;
	NSString *about;
	NSString *aboutHead;
	NSString *ethnic;
	uint32_t height;
	uint32_t weight;
	uint32_t age;
	NSString *likes;
}

//	NSString*   head;
//	NSString*   about;
//	uint32_t*   age;
//	NSString*   sex;
//	NSString*   likes;
//	BOOL        sdist;  // show distance?
//	float		longitude;
//	float		latitude;
//	NSString*	ethnic;
//	uint32_t	height;
//	uint32_t	weight;
//	NSString*   weblink;
//	NSString*   fbLink;
//	NSString*   likes;
//	NSArray*	devices;
//	uint32_t    friendsCount;
//	uint32_t    statusesCount;
//	uint32_t    favoritesCount;
//	BOOL        notifications;
//	BOOL        protected;
//	BOOL        following;
//	time_t      createdAt;
//	time_t      updatedAt;
//	time_t      lastOn;
//}

// {
//	 "_id": {
//		 "$oid": "4c22e72a146728fe80000048"
//	 },
//	 "fbid": 1719,
//	 "name": "Abelardo W",
//	 "head": "Dolor totam est.",
//	 "about": "Laudantium enim dolorem enim. Modi et qui temporibus.",
//	 "age": 19,
//	 "sex": "male",
//	 "likes": "women",
//	 "sdis": true,
//	 "loc": [
//			 40.927955,
//			 -72.204989
//			 ],
//	 "devices": [
//	 
//	 ],
//	 "ethnic": "latino",
//	 "height": 152,
//	 "weight": 126,
//	 "weblink": "www.paucek.info",
//	 "fb_link": "ruth_langworth",
//	 "created": "2010-03-14T21: 20: 14+0000",
//	 "updated": "2010-06-21T08: 09: 13+0000",
//	 "last_on": "2010-06-21T08: 26: 46+0000"
// },
//

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) uint32_t fbid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *about;
@property (nonatomic, copy) NSString* aboutHead;
@property (nonatomic, copy) NSString* ethnic;
@property (nonatomic, copy) NSString* likes;
@property (nonatomic, assign) uint32_t height;
@property (nonatomic, assign) uint32_t weight;
@property (nonatomic, assign) uint32_t age;



- (id)initWithJsonDictionary:(NSDictionary *)dictionary;
//+ (NSArray *)findNearest;

@end
