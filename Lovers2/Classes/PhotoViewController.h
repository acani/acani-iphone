//
//  ProfileViewController.h
//  Lovers
//
//  Created by Jose Lona on 28/04/10.
//  Copyright 2010 fstech. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoViewController : UIViewController {

	UIView * overlay;
	

}

-(IBAction)backButtonClicked:(id)sender;
-(IBAction)moveOverlay:(id)sender;
- (void)goToChat:(id)sender;

@end
