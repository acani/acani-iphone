@interface NSManagedObject (acani)

+ (NSManagedObject *)findByAttribute:(NSString *)attribute
							   value:(NSString *)value
						  entityName:(NSString *)entityName
			  inManagedObjectContext:(NSManagedObjectContext *)context;

@end
