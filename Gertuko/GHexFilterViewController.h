//
//  GHexFilterViewController.h
//  Gertuko
//
//  Created by Nick Bender on 3/8/13.
//  Copyright (c) 2013 AngryMeerkat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHexFilterViewController;

@protocol GHexFilterDelegate <NSObject>

-(void)hexFilterViewController:(GHexFilterViewController *)controller didApplyFilterTypes:(NSArray *)filterTypes;

@end

@interface GHexFilterViewController : UITableViewController

@property (weak) id <GHexFilterDelegate>delegate;
@property (strong, nonatomic) NSArray *filterTypes;

@end
