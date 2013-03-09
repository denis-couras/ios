//
//  GViewController.m
//  Gertuko
//
//  Created by Nick Bender on 3/8/13.
//  Copyright (c) 2013 AngryMeerkat. All rights reserved.
//

#import "GViewController.h"

#import "GHexFilterViewController.h"
#import "GDetailViewController.h"

#import "UIColor+GExtensions.h"

#define NormalMapID  @"gertuko.map-1eb3k819"
#define RetinaMapID  @"gertuko.map-13b3k819"
#define TintColorHex @"#AAAAAA"

@interface GViewController ()

@property (strong) IBOutlet RMMapView *mapView;
@property (strong) NSArray *activeFilterTypes;

@end

@implementation GViewController

@synthesize mapView;
@synthesize activeFilterTypes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString: TintColorHex];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                           target: self action:@selector (presentSearch:)];
    self.navigationItem.leftBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem.tintColor = self.navigationController.navigationBar.tintColor;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    self.mapView.tileSource = [[RMMapBoxSource alloc] initWithMapID:([[UIScreen mainScreen] scale] > 1.0 ? RetinaMapID : NormalMapID) enablingDataOnMapView:self.mapView];
    
    self.mapView.zoom = 2;
    
    [self.mapView setConstraintsSouthWest:[self.mapView.tileSource latitudeLongitudeBoundingBox].southWest northEast:[self.mapView.tileSource latitudeLongitudeBoundingBox].northEast];
    
    self.mapView.showsUserLocation = YES;
    
    self.title = [self.mapView.titleSource shortName];
    
    __weak RMMapView *weakMap = self.mapView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
    {
        float degreeRadius = 9000.f / 110000.f;
        
        CLLocationCoordinate2D centerCoordinate = [((RMMapBoxSource *)self.mapView.tileSource) centerCoordinate];
        
        RMSphericalTrapezium zoomBounds = {
            .southWest = {
                .latitude = centerCoordinate.latitude - degreeRadius,
                .longitude = centerCoordinate.longitude - degreeRadius
            },
            .northEast = {
                .latitude = centerCoordinate.latitude + degreeRadius,
                .longitude = centerCoordinate.longitude + degreeRadius
            }
        };
        
        [weakMap zoomWithLatitudeLongitudeBoundsSouthWest:zoomBounds.southWest
                                                northEast:zoomBounds.northEast animated: YES];
         });
}
                                              

- (void)presentSearch:(id)sender
{
    NSMutableArray *filterTypes = [NSMutableArray array];
    
    for (RMAnnotation *annotation in self.mapView.annotations)
    {
        if (annotation.userInfo && [annotation.userInfo objectForKey:@"marker-symbol"] && ! [[filterTypes valueForKeyPath:@"marker-symbol"] containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]])
        {
            BOOL selected = ( ! self.activeFilterTypes || [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]]);
            
            [filterTypes addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [annotation.userInfo objectForKey:@"marker-symbol"], @"marker-symbol",
                                    [UIImage imageWithCGImage:(CGImageRef)[self mapView:self.mapView layerForAnnotation:annotation].contents], @"image",
                                    [NSNumber numberWithBool:selected], @"selected",
                                    nil]];
        }
    }
    
    GHexFilterViewController *hexViewController = [[GHexFilterViewController alloc] initWithNibName: nil bundle: nil];
    
    hexViewController.delegate = self;
    hexViewController.filterTypes = [NSArray arrayWithArray:filterTypes];
    
    UINavigationController *wrapper [[UINavigationController alloc] initWithRootViewController:hexViewController];
    
    wrapper.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    wrapper.topViewController.title = @"Gertuko";
    
    [self presentmodalViewController:wrapper animated:YES];
}


- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMarker *marker = [[RMMarker alloc] initWithMapBoxMarkerImage:[annotation.userInfo objectForKey:@"marker-symbol"]
                                                      tintColorHex:[annotation.userInfo objectForKey:@"marker-color"]
                                                        sizeString:[annotation.userInfo objectForKey:@"marker-size"]];
    
    marker.canshowCallout = YES;
    
    marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    if (self.activeFilterTypes)
        marker.hidden = ! [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]];
    
    return marker;
}

- (void)hexViewController:(GHexFilterViewController *)controller didApplyFilterTypes:(NSArray *)filterTypes
{
    self.activeFilterTypes = filterTypes;
    
    for (RMAnnotation *annotation in self.mapView.annotations)
        if ( ! annotation.isUserLocationAnnotation)
            annotation.layer.hidden = ! [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]];
}



@end
