//
//  MySearchDisplayController.m
//  xieHui
//
//  Created by LuoHui on 13-7-18.
//
//

#import "MySearchDisplayController.h"

@implementation MySearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive: visible animated: animated];
    
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];
}

@end
