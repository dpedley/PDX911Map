//
//  ViewController.h
//  PDX911Map
//
//  Created by Douglas Pedley on 6/5/13.
//  Copyright (c) 2013 dpedley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

/*
 <entry>
 <id>tag:portlandonline.com,2013-06-05:cad-incidents/PA13000010592</id>
 <title>FLAGDOWN at 0 NORTH LOBBY PIA , PORTLAND, OR</title>
 <updated>2013-06-05T10:52:48.0-07:00</updated>
 <summary>FLAGDOWN at 0 NORTH LOBBY PIA , PORTLAND, OR [Airport Police #PA13000010592]</summary>
 <category label="FLAGDOWN" term="FLAGDOWN" />
 <published>2013-06-05T10:44:59.0-07:00</published>
 <georss:point>45.590207 -122.592553</georss:point>
 <content type="html">
 <dl> <dt>ID:</dt> <dd>PA13000010592</dd> <dt>Call Type:</dt> <dd>FLAGDOWN</dd> <dt>Address:</dt> <dd>0 NORTH LOBBY PIA , PORTLAND, OR</dd> <dt>Agency:</dt> <dd>Airport Police</dd> <dt>Last Updated:</dt> <dd>6/5/13 10:52:48 AM PDT</dd> </dl>
 </content>
 </entry>

 */
@interface IncidentMap : UIViewController <MKMapViewDelegate>

@end
