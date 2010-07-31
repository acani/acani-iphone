//
//  User.h
//  Acani
//
//  Created by Abhinav Sharma on 6/29/10.
//  Copyright 2010 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : NSObject {
	NSString*   userId;
	uint32_t    fbId;
	NSString*   name;
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
//	 "fb_id": 1719,
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



@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) uint32_t fbId;
@property (nonatomic, copy) NSString *name;


- (id)initWithJsonDictionary:(NSDictionary *)dictionary;
+ (NSArray *)findNearest;

@end
