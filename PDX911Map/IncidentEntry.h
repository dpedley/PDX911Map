//
//  IncidentEntry.h
//  PDX911Map
//
//  Created by Douglas Pedley on 6/5/13.
//  Copyright (c) 2013 dpedley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IncidentEntry : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * incidentID;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSString * georss;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
