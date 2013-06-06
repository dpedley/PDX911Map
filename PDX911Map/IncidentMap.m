//
//  ViewController.m
//  PDX911Map
//
//  Created by Douglas Pedley on 6/5/13.
//  Copyright (c) 2013 dpedley. All rights reserved.
//

#import "IncidentMap.h"
#import "IncidentEntry.h"
#import "RestKit.h"
#import "RKXMLReaderSerialization.h"

@interface IncidentAnnotation : NSObject <MKAnnotation>
{
	
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@end

@implementation IncidentAnnotation

@end

@interface IncidentEntry (GeoExtensions)

@property (nonatomic, readonly) CLLocationCoordinate2D geoCoordinate;

@end

@implementation IncidentEntry (GeoExtensions)

@dynamic geoCoordinate;
-(CLLocationCoordinate2D)geoCoordinate
{
	NSArray *ll = [self.georss componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if (ll && [ll count]==2)
	{
		return CLLocationCoordinate2DMake([(NSString *)[ll objectAtIndex:0] doubleValue], [(NSString *)[ll objectAtIndex:1] doubleValue]);
	}
	
	NSLog(@"wtf %@", ll);
	return CLLocationCoordinate2DMake(0,0);
}

@end

@interface IncidentMap ()

@property (nonatomic, strong) IBOutlet MKMapView *map;

@end

@implementation IncidentMap

-(void)updateData
{
//	RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
	[RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/atom+xml"];
	
	// GET an Article and its Categories from /articles/888.json and map into Core Data entities
	// JSON looks like {"article": {"title": "My Article", "author": "Blake", "body": "Very cool!!", "categories": [{"id": 1, "name": "Core Data"]}
	NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
	NSError *error = nil;
	BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
	if (! success) {
		RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
	}
	NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"PDX911.sqlite"];
	NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
	if (! persistentStore) {
		RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
	}
	[managedObjectStore createManagedObjectContexts];
	
	RKEntityMapping *incidentMapping = [RKEntityMapping mappingForEntityForName:@"IncidentEntry" inManagedObjectStore:managedObjectStore];
	[incidentMapping addAttributeMappingsFromDictionary:@{ @"id.text": @"incidentID", @"title.text": @"title",  @"updated.text": @"updated", @"summary.text": @"summary", @"published.text": @"published", @"georss:point.text": @"georss"}];
	
	NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:incidentMapping pathPattern:nil keyPath:@"feed.entry" statusCodes:statusCodes];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.portlandonline.com/scripts/911incidents.cfm"]];
	RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
	operation.managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
	operation.managedObjectCache = managedObjectStore.managedObjectCache;
	[operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
		NSArray *resultsArray = [result array];
		for (IncidentEntry *entry in resultsArray)
		{
			NSLog(@"%@ - %@", entry.updated, entry.title);
			IncidentAnnotation *pin = [[IncidentAnnotation alloc] init];
			pin.coordinate = entry.geoCoordinate;
			pin.title = entry.title;
			pin.subtitle = [entry.updated description];
			[self.map addAnnotation:pin];
		}
	} failure:^(RKObjectRequestOperation *operation, NSError *error) {
		NSLog(@"Failed with error: %@", [error localizedDescription]);
	}];
	NSOperationQueue *operationQueue = [NSOperationQueue new];
	[operationQueue addOperation:operation];
}

#pragma mark - Object lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Portland ,
	[self.map setRegion:MKCoordinateRegionMake( CLLocationCoordinate2DMake(45.517895, -122.674695), MKCoordinateSpanMake(0.2, 0.2))];
	[self updateData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
