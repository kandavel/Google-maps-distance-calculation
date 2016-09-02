//
//  ViewController.m
//  vibes
//
//  Created by Kandavel on 27/08/16.
//  Copyright © 2016 com.base2. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperation.h"

@interface ViewController ()<CLLocationManagerDelegate,GMSMapViewDelegate>
{
    // declaration-------------------------------------------> nsobject for gmservies
    NSArray *latitude;
    NSArray *longitude;
    NSArray *lines;
    NSString *google_api;
    NSDictionary *resultDictionary;
    NSString *fetchedAddress;
    double fetchedLatitude;
    double fetchedlongitude;
    NSDictionary *fetchedGeometry;
    NSString *originAddress;
    //declaration-------------------------------------------->nsobject for routes
    NSString *routes_API;
    NSDictionary *routes_Direction;
    NSDictionary *routes_Polyline;
    CLLocationCoordinate2D routes_Origin;
    CLLocationCoordinate2D routes_Destination;
    NSString *routesOriginAddress;
    NSString *routesDestinationAddress;
    GMSPolyline *polylinePath;
    //declaration-------------------------------------------->waypoints
   NSArray *markerArray;
    NSArray *waypointsArray;
    NSString *stringRoute;
    NSDictionary *startCoordinate;
    NSDictionary *endCoordinate;
    //declaration-------------------------------------------->Gmaps declaration
    GMSCameraPosition *cameraPosition;
    CLLocationManager *locationmanager;
    GMSMarker *marker;
    GMSMarker *markerDestination;

   //declaration---------------------------------------------->UIkit declaration
    UIAlertController *alert;
    UIAlertAction *alertAction1;
    UIAlertAction *alertAction2;
   
}
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *search;
- (IBAction)searchAction:(id)sender;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
-(void)searchaddress:(NSString*)address;
-(void)getroutesdirection:(NSString*)origin destinationaddress:(NSString*)destination;
-(void)getsDistance:(NSDictionary*)dictionary1 getsDuration:(NSDictionary*)dictionary2;
-(void)clearRoute;
-(void)recreateRoute;
-(void)getroutesdirection:(NSString*)origin destinationaddress:(NSString*)destination waypointsArray:(NSArray*)waypointsarray;
@end
//48.857165
//2.354613
@implementation ViewController

- (void)viewDidLoad
{
     [super viewDidLoad];
    //initialization----------------------------------------------------------->gmservies
    latitude=[[NSArray alloc]init];
    longitude=[[NSArray alloc]init];
    lines=[[NSArray alloc]init];
    resultDictionary=[[NSDictionary alloc]init];
    google_api=@"https://maps.googleapis.com/maps/api/geocode/json?";
    cameraPosition=[GMSCameraPosition cameraWithLatitude:48.857165 longitude:2.354613 zoom:8.0 bearing:0 viewingAngle:0];
    //initialization----------------------------------------------------------->groutes
    routes_API=@"https://maps.googleapis.com/maps/api/directions/json?";
    routes_Direction=[[NSDictionary alloc] init];
    routes_Polyline=[[NSDictionary alloc] init];
    startCoordinate=[[NSDictionary alloc]init];
    endCoordinate=[[NSDictionary alloc]init];
    //initialization----------------------------------------------------------->optimizedroutes
    waypointsArray =[[NSArray alloc]init];
    markerArray=[[NSArray alloc]init];
    [self.mapView setCamera:cameraPosition];
    [self.mapView setMapType:kGMSTypeNormal];
    [self.mapView setMyLocationEnabled:YES];
    [self.mapView.settings setCompassButton:YES];
    [self.mapView.settings setMyLocationButton:YES];
    [self.mapView.settings setZoomGestures:YES];
    [self.mapView setDelegate:self];
    [self.mapView setPadding:UIEdgeInsetsMake(10, 10, 10, 10)];
    locationmanager=[[CLLocationManager alloc]init];
    [locationmanager setDistanceFilter:10];
    [locationmanager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationmanager setDelegate:self];
    [locationmanager requestWhenInUseAuthorization];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{

    if (status==kCLAuthorizationStatusAuthorizedAlways )
    {
        [locationmanager startUpdatingLocation];
    }

    if (status==kCLAuthorizationStatusAuthorizedWhenInUse )
    {
        
        
        [locationmanager startUpdatingLocation];
    }
    
}
/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:self.mapView.myLocation.coordinate.latitude
                                                                                 longitude:self.mapView.myLocation.coordinate.longitude
                                                                                      zoom:8.0]];
    }
}

*/
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    if (locations!=nil)
    {
        //marker
        marker=[GMSMarker markerWithPosition:[[locations lastObject] coordinate]];
        marker.appearAnimation=kGMSMarkerAnimationPop;
        marker.tracksViewChanges=YES;
        marker.position=[[locations firstObject] coordinate];
       // marker.tappable=YES;
        [marker setDraggable:1];
         marker.groundAnchor = CGPointMake(1.0, 1.0);
        
        //set coordinates to map view
        self.mapView.camera=[GMSCameraPosition cameraWithTarget:[[locations lastObject] coordinate] zoom:8.0 bearing:0 viewingAngle:0];
        
        // finding coordinates to current loaction
        [[GMSGeocoder geocoder]reverseGeocodeCoordinate:[[locations lastObject] coordinate]
                                      completionHandler:^(GMSReverseGeocodeResponse * response, NSError *error){
                                          NSLog(@"%@",response.results);
                                          for(GMSReverseGeocodeResult *result in response.results)
                                          {
                                               NSLog(@"%@",lines);
                                              marker.title=[NSString stringWithFormat:@"%f\t%@%@%f\t%@",result.coordinate.latitude ,@"lat",@",",result.coordinate.longitude,@"lon"];
                                              lines=[lines arrayByAddingObjectsFromArray:result.lines];
                                              marker.position=result.coordinate;
                                              
                                          }
                                          
                                          NSLog(@"%@",lines);
                                         
                                          originAddress=[NSString stringWithFormat:@"%@%@",[lines firstObject],[lines objectAtIndex:1]];
                                          marker.snippet=originAddress;
                                          marker.map=self.mapView;
                                      }];
        
       
        
       
                        
        
        [locationmanager stopUpdatingLocation];

    }
    

}
- (IBAction)searchAction:(id)sender
{
    
    alert=[UIAlertController alertControllerWithTitle:@"Address" message:@"Enter the addresss you want" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         
         textField.placeholder=@"Enter the address";
         textField.clearButtonMode=UITextFieldViewModeWhileEditing;
     }];
    
    alertAction1=[UIAlertAction actionWithTitle:@"Find address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        
        NSLog(@"%@",[[alert textFields] objectAtIndex:0].text);
        
        [self searchaddress:[[alert textFields] objectAtIndex:0].text];
    }
                ];
    alertAction2=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                  {
                      [alert dismissViewControllerAnimated:YES completion:nil];
                  }
                  ];
    
   
    
    [alert addAction:alertAction1];
    [alert addAction:alertAction2];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)searchaddress:(NSString *)address
{
    
    NSString *str=[NSString stringWithFormat:@"%@%@%@",@"https://maps.googleapis.com/maps/api/geocode/json?",@"address=",address];
    
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url=[NSURL URLWithString:str];
    
    
    NSMutableURLRequest *af_request=[NSMutableURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:af_request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@",dic);
        
        NSLog(@"%@",[dic allKeys]);
        
        
        if ([[dic objectForKey:@"status"]isEqualToString:@"OK"])
        {
           
            NSLog(@"%@",[dic objectForKey:@"results"]);
            
            NSArray *resultArray=[dic objectForKey:@"results"];
            NSLog(@"%@",resultArray);
           resultDictionary=[resultArray  lastObject];
            fetchedAddress=[resultDictionary objectForKey:@"formatted_address"];
            fetchedGeometry=[resultDictionary objectForKey:@"geometry"];
            fetchedLatitude=[[[fetchedGeometry objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
            fetchedlongitude=[[[fetchedGeometry objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
            
            
           
            
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:CLLocationCoordinate2DMake(fetchedLatitude, fetchedlongitude) zoom:8.0]] ;
            
            
            marker=[GMSMarker markerWithPosition:CLLocationCoordinate2DMake(fetchedLatitude, fetchedlongitude)];
            marker.appearAnimation=kGMSMarkerAnimationPop;
            marker.tracksViewChanges=YES;
            marker.position=CLLocationCoordinate2DMake(fetchedLatitude, fetchedlongitude);
           // marker.tappable=YES;
            [marker setDraggable:1];
            marker.groundAnchor = CGPointMake(1.0, 1.0);
            marker.flat=YES;
            marker.opacity=0.67;
            marker.title=[NSString stringWithFormat:@"%f\t%@%@%f\t%@",fetchedLatitude,@"lat",@",",fetchedlongitude,@"lon"];
            marker.snippet=fetchedAddress;
            marker.map=self.mapView;
            
            [self getroutesdirection:originAddress destinationaddress:fetchedAddress];
            
        }
        if ([[dic objectForKey:@"status "] isEqualToString:@"ZERO_RESULTS"])
        {
           
            alert=[UIAlertController alertControllerWithTitle:@"Wrong" message:@"You Entered the wrong address" preferredStyle:UIAlertControllerStyleAlert];
            
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
             {
                 
                 textField.placeholder=@"Enter the address";
                 textField.clearButtonMode=UITextFieldViewModeWhileEditing;
             }];
            
            
            alertAction1=[UIAlertAction actionWithTitle:@"Find address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                          {
                              
                              NSLog(@"%@",[[alert textFields] objectAtIndex:0].text);
                              
                              [self searchaddress:[[alert textFields] objectAtIndex:0].text];
                          }
                          ];
            alertAction2=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                          }
                          ];
            
            
            
            [alert addAction:alertAction1];
            [alert addAction:alertAction2];
            [self presentViewController:alert animated:YES completion:nil];

            
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
        alert=[UIAlertController alertControllerWithTitle:[error localizedDescription] message:[error localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
        
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             
             textField.placeholder=@"Enter the address";
             textField.clearButtonMode=UITextFieldViewModeWhileEditing;
         }];
        
    
     
     alertAction1=[UIAlertAction actionWithTitle:@"Find address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                   {
                       
                       NSLog(@"%@",[[alert textFields] objectAtIndex:0].text);
                       
                       [self searchaddress:[[alert textFields] objectAtIndex:0].text];
                   }
                   ];
     alertAction2=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                   {
                       [alert dismissViewControllerAnimated:YES completion:nil];
                   }
                   ];
        
     [alert addAction:alertAction1];
     [alert addAction:alertAction2];
     [self presentViewController:alert animated:YES completion:nil];
     

     
    }];
    
    [operation start];
}
-(void)getroutesdirection:(NSString*)origin destinationaddress:(NSString*)destination
{

    if (origin!=nil&&destination!=nil)
    {
      
        NSString *stringRoute1=[NSString stringWithFormat:@"%@%@%@%@%@",routes_API,@"origin=",origin,@"&destination=",destination];
       stringRoute1= [stringRoute1 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url=[NSURL URLWithString:stringRoute1];
        
        
        NSMutableURLRequest *af_request=[NSMutableURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:af_request];
        operation.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
             NSLog(@"%@",dic);
             
             NSLog(@"%@",[dic allKeys]);
             
            if ([[dic objectForKey:@"status"]isEqualToString:@"OK"])
            {
            
                
                routes_Direction=[[dic objectForKey:@"routes"] objectAtIndex:0];
                routes_Polyline=[routes_Direction objectForKey:@"overview_polyline"];
             
                NSLog(@"%@",[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"start_location"]);
                
                startCoordinate=[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"start_location"];
                
                     routes_Origin=CLLocationCoordinate2DMake([[startCoordinate objectForKey:@"lat"] doubleValue],[[startCoordinate objectForKey:@"lng"] doubleValue]);
                
               endCoordinate=[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"end_location"];
                
                routes_Destination=CLLocationCoordinate2DMake([[endCoordinate objectForKey:@"lat"] doubleValue],[[endCoordinate objectForKey:@"lng"] doubleValue]);
                
                routesOriginAddress=[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"start_address"];
                routesDestinationAddress=[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"end_address"];
                
            NSLog(@"%@",   [GMSPath pathFromEncodedPath:[[routes_Direction objectForKey:@"overview_polyline"] objectForKey:@"points"]]);
                NSLog(@"%@",[[routes_Direction objectForKey:@"overview_polyline"] objectForKey:@"points"]);
                
                GMSPath *path=[GMSPath pathFromEncodedPath:[[routes_Direction objectForKey:@"overview_polyline"] objectForKey:@"points"]];
                polylinePath=[[GMSPolyline alloc] init];
                [polylinePath setSpans:@[[GMSStyleSpan spanWithColor:[UIColor blueColor]]]];
                [polylinePath setPath:path];
                [polylinePath setStrokeWidth:5.0f];
                [polylinePath setGeodesic:YES];
                [polylinePath setMap:self.mapView];
                [self getsDistance:[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"distance"] getsDuration:[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"]];
                
                           }
             if ([[dic objectForKey:@"status "] isEqualToString:@"ZERO_RESULTS"])
             {
                 
                 alert=[UIAlertController alertControllerWithTitle:@"Wrong" message:@"You Entered the wrong address" preferredStyle:UIAlertControllerStyleAlert];
                 
                 
                 [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
                  {
                      
                      textField.placeholder=@"Enter the address";
                      textField.clearButtonMode=UITextFieldViewModeWhileEditing;
                  }];
                 
                 
                 alertAction1=[UIAlertAction actionWithTitle:@"Find address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                               {
                                   
                                   NSLog(@"%@",[[alert textFields] objectAtIndex:0].text);
                                   
                                   [self searchaddress:[[alert textFields] objectAtIndex:0].text];
                               }
                               ];
                 alertAction2=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }
                               ];
                 
                 
                 
                 [alert addAction:alertAction1];
                 [alert addAction:alertAction2];
                 [self presentViewController:alert animated:YES completion:nil];
                 
                 
             }
             
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             
             alert=[UIAlertController alertControllerWithTitle:[error localizedDescription] message:[error localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
             
             
             [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
              {
                  
                  textField.placeholder=@"Enter the address";
                  textField.clearButtonMode=UITextFieldViewModeWhileEditing;
              }];
             
             
             
             alertAction1=[UIAlertAction actionWithTitle:@"Find address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                           {
                               
                               NSLog(@"%@",[[alert textFields] objectAtIndex:0].text);
                               
                               [self searchaddress:[[alert textFields] objectAtIndex:0].text];
                           }
                           ];
             alertAction2=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                           {
                               [alert dismissViewControllerAnimated:YES completion:nil];
                           }
                           ];
             
             [alert addAction:alertAction1];
             [alert addAction:alertAction2];
             [self presentViewController:alert animated:YES completion:nil];
             
             
             
         }];
        
        [operation start];
    }
    
    
}
-(void)getsDistance:(NSDictionary*)dictionary1 getsDuration:(NSDictionary*)dictionary2
{


    NSLog(@"%@",dictionary1);
    NSLog(@"%@",dictionary2);

    double distance=0;
    double duration=0;
    
    distance=distance+[[dictionary1 objectForKey:@"value"] doubleValue];
    duration=duration+[[dictionary2 objectForKey:@"value"] doubleValue];

    unsigned int min=duration/60;
    unsigned int hours=min/60;
    unsigned int days=hours/24;
    unsigned int remainingMinute=min%60;
    unsigned int remainingHours=hours%24;
    
    NSString *distanceDuration=[NSString stringWithFormat:@"TotalDistance:\t%f%@",distance/1000,@"km"];
    NSString *displayDuration=[NSString stringWithFormat:@"TotalDuration:\t%uDays\t:\t%uRhours:\t%uRmin",days,remainingHours,remainingMinute] ;
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.firstLineHeadIndent = 10.0f;
    style.headIndent = 10.0f;
   
    
  
    
    _duration.attributedText=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n%@",distanceDuration,displayDuration] attributes:@{NSParagraphStyleAttributeName : style}];
     [_duration setContentMode:UIViewContentModeCenter];
       [_duration  setNumberOfLines:0];
    [_duration setAdjustsFontSizeToFitWidth:YES];

    
    }
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{

    if (polylinePath!=nil)
    {
       
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        waypointsArray=[waypointsArray arrayByAddingObject:location];
        
        
        [self recreateRoute];
       
        
    }
   //  [self optimizedroute];
}
-(void)configureMapAndMarkersForRoute
{

    
    
    
    
    
    
    GMSMarker  *markerORIGIN=[GMSMarker markerWithPosition:CLLocationCoordinate2DMake([[startCoordinate objectForKey:@"lat"] doubleValue], [[startCoordinate objectForKey:@"lng"] doubleValue])];
     markerORIGIN.appearAnimation=kGMSMarkerAnimationPop;
     markerORIGIN.tracksViewChanges=YES;
       markerORIGIN.position=CLLocationCoordinate2DMake(fetchedLatitude, fetchedlongitude);
     markerORIGIN.tappable=YES;
     [markerORIGIN setDraggable:1];
    [markerORIGIN setIcon:[GMSMarker markerImageWithColor:[UIColor blueColor]]];
     markerORIGIN.groundAnchor = CGPointMake(1.0, 1.0);
     //marker.flat=YES;
     markerORIGIN.title=[NSString stringWithFormat:@"%f\t%@%@%f\t%@",[[startCoordinate objectForKey:@"lat"] doubleValue],@"lat",@",",[[startCoordinate objectForKey:@"lng"] doubleValue],@"lon"];
     markerORIGIN.snippet=routesOriginAddress;
     markerORIGIN.map=self.mapView;
     
  GMSMarker   *markerDest=[GMSMarker markerWithPosition:CLLocationCoordinate2DMake([[endCoordinate objectForKey:@"lat"] doubleValue], [[endCoordinate objectForKey:@"lng"] doubleValue])];
     markerDest.appearAnimation=kGMSMarkerAnimationPop;
     markerDest.tracksViewChanges=YES;
       markerDest.position=CLLocationCoordinate2DMake(fetchedLatitude, fetchedlongitude);
     markerDest.tappable=YES;
     [markerDest setDraggable:1];
     [markerDest setIcon:[GMSMarker markerImageWithColor:[UIColor greenColor]]];
     markerDest.groundAnchor = CGPointMake(1.0, 1.0);
    // markerDest.flat=YES;
     markerDest.title=[NSString stringWithFormat:@"%f\t%@%@%f\t%@",[[endCoordinate objectForKey:@"lat"] doubleValue],@"lat",@",",[[endCoordinate objectForKey:@"lng"] doubleValue],@"lon"];
     markerDest.snippet=routesDestinationAddress;
     markerDest.map=self.mapView;

    GMSPath *path=[GMSPath pathFromEncodedPath:[[routes_Direction objectForKey:@"overview_polyline"] objectForKey:@"points"]];
    polylinePath=[[GMSPolyline alloc] init];
    [polylinePath setSpans:@[[GMSStyleSpan spanWithColor:[UIColor greenColor]]]];
    [polylinePath setPath:path];
    [polylinePath setStrokeWidth:5.0f];
    [polylinePath setGeodesic:YES];
    [polylinePath setMap:self.mapView];
    
    if (waypointsArray.count>0)
    {
        
        for (CLLocation *loc in waypointsArray)
        {
            
            
            NSLog(@"%f",loc.coordinate.latitude);
            NSLog(@"%f",loc.coordinate.longitude);
            
            CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake( loc.coordinate.latitude, loc.coordinate.longitude);
            
            GMSMarker *markerOptimaizaed=[GMSMarker markerWithPosition:coordinate];
            markerOptimaizaed.map=self.mapView;
            markerOptimaizaed.icon=[GMSMarker markerImageWithColor:[UIColor orangeColor ]];
            markerArray=[markerArray arrayByAddingObject:markerOptimaizaed];
            
            
        }
        
        
    }

}
-(void)clearRoute
{
    
    marker.map=nil;
    markerDestination.map=nil;
    polylinePath.map=nil;
    marker=nil;
    polylinePath=nil;
    NSLog(@"%@",polylinePath);
    markerDestination=nil;
    
    if (markerArray.count>0)
    {
        
        for (GMSMarker *markerremove in markerArray)
        {
           
            markerremove.map=nil;
            
        }
        
        NSLog(@"%@",markerArray);
    }

}
-(void)recreateRoute
{

    if (polylinePath!=nil)
    {
        
        [self clearRoute];
        
        [self getroutesdirection:routesOriginAddress destinationaddress:routesDestinationAddress waypointsArray:waypointsArray];
        
        [self configureMapAndMarkersForRoute];
        
    }


}
-(void)getroutesdirection:(NSString*)origin destinationaddress:(NSString*)destination waypointsArray:(NSArray*)waypointsarray
{

   
    
    
    
    for (CLLocation *logi in waypointsArray)
    {
        
       stringRoute=[NSString stringWithFormat:@"%@%@%@%@%@%@%@",routes_API,@"origin=",origin,@"&destination=",destination,@"waypoints=optimize:true", [@"|" stringByAppendingString:[NSString stringWithFormat:@"%f%@%f",logi.coordinate.latitude,@",",logi.coordinate.longitude]]];
        NSLog(@"%@",stringRoute);
    }
    stringRoute= [stringRoute stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url=[NSURL URLWithString:stringRoute];
    NSMutableURLRequest *af_request=[NSMutableURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:af_request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         NSLog(@"%@",dic);
         
         NSLog(@"%@",[dic allKeys]);
         
         if ([[dic objectForKey:@"status"]isEqualToString:@"OK"])
         {
             
             
             routes_Direction=[[dic objectForKey:@"routes"] objectAtIndex:0];
             routes_Polyline=[routes_Direction objectForKey:@"overview_polyline"];
             
             NSLog(@"%@",[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"start_location"]);
             
             startCoordinate=[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"start_location"];
             
             routes_Origin=CLLocationCoordinate2DMake([[startCoordinate objectForKey:@"lat"] doubleValue],[[startCoordinate objectForKey:@"lng"] doubleValue]);
             
             endCoordinate=[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"end_location"];
             
             routes_Destination=CLLocationCoordinate2DMake([[endCoordinate objectForKey:@"lat"] doubleValue],[[endCoordinate objectForKey:@"lng"] doubleValue]);
             
             routesOriginAddress=[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"start_address"];
             routesDestinationAddress=[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"end_address"];
             
             NSLog(@"%@",   [GMSPath pathFromEncodedPath:[[routes_Direction objectForKey:@"overview_polyline"] objectForKey:@"points"]]);
             NSLog(@"%@",[[routes_Direction objectForKey:@"overview_polyline"] objectForKey:@"points"]);
             
             
             
             [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:CLLocationCoordinate2DMake([[endCoordinate objectForKey:@"lat"] doubleValue], [[endCoordinate objectForKey:@"lng"] doubleValue]) zoom:8.0]] ;
             
             
             
             
             [self getsDistance:[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"distance"] getsDuration:[[[routes_Direction objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"]];
          
            
             
             
         }
         if ([[dic objectForKey:@"status "] isEqualToString:@"ZERO_RESULTS"])
         {
             
             alert=[UIAlertController alertControllerWithTitle:@"Wrong" message:@"You Entered the wrong address" preferredStyle:UIAlertControllerStyleAlert];
             
             
             [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
              {
                  
                  textField.placeholder=@"Enter the address";
                  textField.clearButtonMode=UITextFieldViewModeWhileEditing;
              }];
             
             
             alertAction1=[UIAlertAction actionWithTitle:@"Find address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                           {
                               
                               NSLog(@"%@",[[alert textFields] objectAtIndex:0].text);
                               
                               [self searchaddress:[[alert textFields] objectAtIndex:0].text];
                           }
                           ];
             alertAction2=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                           {
                               [alert dismissViewControllerAnimated:YES completion:nil];
                           }
                           ];
             
             
             
             [alert addAction:alertAction1];
             [alert addAction:alertAction2];
             [self presentViewController:alert animated:YES completion:nil];
             
            
         
         }
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         alert=[UIAlertController alertControllerWithTitle:[error localizedDescription] message:[error localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
         
         
         [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
          {
              
              textField.placeholder=@"Enter the address";
              textField.clearButtonMode=UITextFieldViewModeWhileEditing;
          }];
         
         
         
         alertAction1=[UIAlertAction actionWithTitle:@"Find address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                       {
                           
                           NSLog(@"%@",[[alert textFields] objectAtIndex:0].text);
                           
                           [self searchaddress:[[alert textFields] objectAtIndex:0].text];
                       }
                       ];
         alertAction2=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                       {
                           [alert dismissViewControllerAnimated:YES completion:nil];
                       }
                       ];
         
         [alert addAction:alertAction1];
         [alert addAction:alertAction2];
         [self presentViewController:alert animated:YES completion:nil];
         
         
         
     }];
    
    [operation start];
    
    
}
@end
