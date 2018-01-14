/* Copyright (c) 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "HeatmapViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import "Heatmap/GMUHeatmapTileLayer.h"
#import "Heatmap/GMUWeightedLatLng.h"
#import "DevApp-Swift.h"

static const double kCameraLatitude = 50.067959;
static const double kCameraLongitude = 19.91266;

@interface HeatmapViewController ()<GMSMapViewDelegate>
@end

@implementation HeatmapViewController {
    GMSMapView *_mapView;
    GMUWeightBasedHeatmapTileLayer *weightHeatmap;
}

- (void)loadView {
    GMSCameraPosition *camera =
    [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:14];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = _mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    weightHeatmap = [[GMUWeightBasedHeatmapTileLayer alloc] initWithWeightedData: [self generateHeatmapItems]];
    weightHeatmap.map = _mapView;
    [weightHeatmap setRadiusWithRadius:200];
    [weightHeatmap setOpacityWithOpacity:0.7];
    [weightHeatmap setMaxIntensityWithMaxIntensity:100.0];
    
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(removeHeatmap)];
    self.navigationItem.rightBarButtonItems = @[ removeButton ];
}

#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"Tapped at location: (%lf, %lf)", coordinate.latitude, coordinate.longitude);
}

#pragma mark Private

- (NSMutableArray<GMUWeightedLatLng *> *)generateHeatmapItems {
    NSMutableArray<GMUWeightedLatLng *> *items = [NSMutableArray arrayWithCapacity:1];
    
    items[0] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.986111, 20.061667) intensity:99.0];
    items[1] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.193139, 20.288717) intensity:1.0];
    items[2] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.740278, 19.588611) intensity:1.0];
    items[3] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.061389, 19.938333) intensity:1.0];
    items[4] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.174722, 20.986389) intensity:1.0];
    items[5] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.064507, 19.920777) intensity:23.0];
    items[6] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.3, 19.95) intensity:1.0];
    items[7] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.833333, 19.940556) intensity:1.0];
    items[8] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.477778, 20.03) intensity:1.0];
    items[9] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.975, 19.828333) intensity:1.0];
    items[10] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.357778, 20.0325) intensity:1.0];
    items[11] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.0125, 20.988333) intensity:1.0];
    items[12] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.067959, 19.91266) intensity:76.0];
    items[13] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.418588, 20.323788) intensity:63.0];
    items[14] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.62113, 20.710777) intensity:25.0];
    items[15] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.039167, 19.220833) intensity:1.0];
    items[16] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.970495, 19.837214) intensity:48.0];
    items[17] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.701667, 20.425556) intensity:1.0];
    items[18] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.078429, 20.050861) intensity:43.0];
    items[19] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.895, 21.054167) intensity:1.0];
    items[20] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.27722, 19.569658) intensity:50.0];
    items[21] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.968889, 20.606389) intensity:1.0];
    items[22] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.51232, 19.63755) intensity:29.0];
    items[23] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.018077, 20.989849) intensity:50.0];
    items[24] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.081698, 19.895629) intensity:32.0];
    items[25] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.968889, 20.43) intensity:1.0];
    items[26] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.279167, 19.559722) intensity:1.0];
    items[27] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.067947, 19.912865) intensity:52.0];
    items[28] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.654444, 21.159167) intensity:1.0];
    items[29] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.099606, 20.016707) intensity:27.0];
    items[30] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.357778, 20.0325) intensity:41.0];
    items[31] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.296628, 19.959694) intensity:15.0];
    items[32] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.019014, 21.002474) intensity:57.0];
    items[33] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.056829, 19.926414) intensity:51.0];
    items[34] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.616667, 20.7) intensity:1.0];
    items[35] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.883333, 19.5) intensity:1.0];
    items[36] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.054217, 19.943289) intensity:41.0];
    items[37] = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.133333, 19.4) intensity:1.0];
    return items;
}

- (void)removeHeatmap {
    weightHeatmap.map = nil;
    weightHeatmap = nil;
}

@end
