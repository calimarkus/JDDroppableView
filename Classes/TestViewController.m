//
//  TestViewController.m
//  DroppableViewTest
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright Markus Emrich 2010. All rights reserved.
//

#import "TestViewController.h"
#import "JDDroppableView.h"

#import <QuartzCore/QuartzCore.h>


// setup view vars
static NSInteger sDROPVIEW_MARGIN = 3;
static CGFloat   sCOUNT_OF_VIEWS_HORICONTALLY = 4.0;

@interface TestViewController ()
@property (nonatomic,assign) CGSize cardSize;
@end

@implementation TestViewController

- (void)loadView
{
	[super loadView];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    // increase viewcount on ipad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sCOUNT_OF_VIEWS_HORICONTALLY = 6;
    }
    
    // add button
    UIButton* button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [button setTitle: @"+" forState: UIControlStateNormal];
    [button addTarget: self action: @selector(addView:) forControlEvents: UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithRed: 0.75 green: 0.2 blue: 0 alpha: 1.0];
    button.layer.cornerRadius = 5.0;
    button.showsTouchWhenHighlighted = YES;
    button.adjustsImageWhenHighlighted = YES;
    button.frame = CGRectMake(20,
                              self.view.frame.size.height - 52,
                              self.view.frame.size.width - 40, // width
                              32); // height
    [self.view addSubview: button];
	
	// drop target 1
	self.dropTarget1 = [[UIView alloc] init];
    self.dropTarget1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	self.dropTarget1.backgroundColor = [UIColor orangeColor];
	self.dropTarget1.frame = CGRectMake(0, 0, 30, 30);
	self.dropTarget1.center = CGPointMake(self.view.frame.size.width/2 - 50, button.frame.origin.y - 50);
    self.dropTarget1.layer.cornerRadius = 15;
	[self.view addSubview: self.dropTarget1];
	
	// drop target 2
	self.dropTarget2 = [[UIView alloc] init];
    self.dropTarget2.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	self.dropTarget2.backgroundColor = [UIColor orangeColor];
	self.dropTarget2.frame = CGRectMake(0, 0, 30, 30);
	self.dropTarget2.center = CGPointMake(self.view.frame.size.width/2 + 50, button.frame.origin.y - 50);
    self.dropTarget2.layer.cornerRadius = 15;
	[self.view addSubview: self.dropTarget2];
	
	// scrollview
	self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.backgroundColor = [UIColor colorWithRed: 0.75 green: 0.2 blue: 0 alpha: 1.0];
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 5, 5, 5);
	self.scrollView.contentInset = UIEdgeInsetsMake(6, 6, 6, 6);
    self.scrollView.layer.cornerRadius = 5.0;
	self.scrollView.frame = CGRectMake(20,20, self.view.frame.size.width - 40, self.dropTarget1.center.y - 70);
    self.scrollView.userInteractionEnabled = NO;
	self.scrollView.canCancelContentTouches = NO;
	[self.view addSubview: self.scrollView];
    
    // calculate card size
    CGFloat contentWidth  = self.scrollView.frame.size.width  - self.scrollView.contentInset.left - self.scrollView.contentInset.right;
    CGFloat width = ((contentWidth-sDROPVIEW_MARGIN*(sCOUNT_OF_VIEWS_HORICONTALLY-1))/sCOUNT_OF_VIEWS_HORICONTALLY);
	self.cardSize = CGSizeMake(width,floor(width/10*18));
	
	// animate some draggable views in
    NSInteger rowCount = ceil(self.scrollView.frame.size.height/self.cardSize.height);
    NSInteger numberOfViews = sCOUNT_OF_VIEWS_HORICONTALLY * rowCount - 2;
    CGFloat animationTimePerView = 0.15;
	for (int i = 0; i < numberOfViews; i++) {
		[self performSelector: @selector(addView:) withObject: nil afterDelay: i*animationTimePerView];
        if (i%(int)sCOUNT_OF_VIEWS_HORICONTALLY==0) {
            [self performSelector: @selector(scrollToBottomAnimated:) withObject: [NSNumber numberWithBool: YES] afterDelay: i*animationTimePerView];
        }
	}
    
    // reenable userinteraction after animation ended
    [self.scrollView performSelector: @selector(setUserInteractionEnabled:) withObject: [NSNumber numberWithBool: YES] afterDelay: numberOfViews*animationTimePerView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma layout

- (void)relayout
{
    // cancel all animations
    [self.scrollView.layer removeAllAnimations];
	for (UIView* subview in self.scrollView.subviews)
        [subview.layer removeAllAnimations];
    
    // setup new animation
	[UIView beginAnimations: @"drag" context: nil];
    
    // init calculation vars
	float posx = 0;
	float posy = 0;
	CGRect frame = CGRectZero;
    self.lastPosition = CGPointMake(0, -100);
    CGFloat contentWidth = self.scrollView.contentSize.width - self.scrollView.contentInset.left - self.scrollView.contentInset.right;
	
    // iterate through all subviews
	for (UIView* subview in self.scrollView.subviews)
    {
        // ignore scroll indicators
        if (!subview.userInteractionEnabled) {
            continue;
        }
        
        // create new position
		frame = subview.frame;
        frame.origin.x = posx;
        frame.origin.y = posy;
        
        // update frame (if it did change)
        if (frame.origin.x != subview.frame.origin.x ||
            frame.origin.y != subview.frame.origin.y) {
            subview.frame = frame;
        }
        
        // save last position
        self.lastPosition = CGPointMake(posx, posy);
		
        // add size and margin
		posx += frame.size.width + sDROPVIEW_MARGIN;
		
        // goto next row if needed
		if (posx > self.scrollView.frame.size.width - self.scrollView.contentInset.left - self.scrollView.contentInset.right)
        {
			posx = 0;
			posy += frame.size.height + sDROPVIEW_MARGIN;
		}
	}
    
    // fix last posy for correct contentSize
    if (posx != 0) {
        posy += frame.size.height;
    } else {
        posy -= sDROPVIEW_MARGIN;
    }
    
    // update content size
    self.scrollView.contentSize = CGSizeMake(contentWidth, posy);
    
	[UIView commitAnimations];
}

- (void)addView:(id)sender
{
    JDDroppableView * dropview = [[JDDroppableView alloc] initWithDropTarget: self.dropTarget1];
    [dropview addDropTarget:self.dropTarget2];
    dropview.backgroundColor = [UIColor blackColor];
    dropview.layer.cornerRadius = 3.0;
    dropview.frame = CGRectMake(self.lastPosition.x, self.lastPosition.y, self.cardSize.width, self.cardSize.height);
    dropview.delegate = self;
    
    [self.scrollView addSubview: dropview];
    
    [self relayout];
    
    // scroll to bottom, if added manually
    if ([sender isKindOfClass: [UIButton class]]) {
        [self scrollToBottomAnimated: YES];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self.scrollView.layer removeAllAnimations];
    
    CGFloat bottomScrollPosition = self.scrollView.contentSize.height;
    bottomScrollPosition -= self.scrollView.frame.size.height;
    bottomScrollPosition += self.scrollView.contentInset.top;
    bottomScrollPosition = MAX(-self.scrollView.contentInset.top,bottomScrollPosition);
    CGPoint newOffset = CGPointMake(-self.scrollView.contentInset.left, bottomScrollPosition);
    if (newOffset.y != self.scrollView.contentOffset.y) {
        [self.scrollView setContentOffset: newOffset animated: animated];
    }
}


#pragma JDDroppableViewDelegate

- (void)droppableViewBeganDragging:(JDDroppableView*)view;
{
//    NSLog(@"droppableViewBeganDragging");
    
	[UIView animateWithDuration:0.33 animations:^{
        view.backgroundColor = [UIColor colorWithRed:1 green:0.5 blue:0 alpha:1];
        view.alpha = 0.8;
    }];
}

- (void)droppableViewDidMove:(JDDroppableView*)view;
{
//    NSLog(@"droppableViewDidMove:");
}

- (void)droppableViewEndedDragging:(JDDroppableView*)view onTarget:(UIView *)target
{
//    NSLog(@"droppableViewEndedDragging:onTarget: %@", target == nil ? @"no target" : @"on target");
    
	[UIView animateWithDuration:0.33 animations:^{
        if (!target) {
            view.backgroundColor = [UIColor blackColor];
        } else {
            view.backgroundColor = [UIColor darkGrayColor];
        }
        view.alpha = 1.0;
    }];
}

- (void)droppableView:(JDDroppableView*)view enteredTarget:(UIView*)target
{
//    NSLog(@"droppableView:enteredTarget: %@", target == self.dropTarget1 ? @"one" : @"two");
    
    target.transform = CGAffineTransformMakeScale(1.5, 1.5);
    
    if (target == self.dropTarget1) {
        target.backgroundColor = [UIColor greenColor];
    } else {
        target.backgroundColor = [UIColor redColor];
    }
}

- (void)droppableView:(JDDroppableView*)view leftTarget:(UIView*)target
{
//    NSLog(@"droppableView:leftTarget: %@", target == self.dropTarget1 ? @"one" : @"two");
    
    target.transform = CGAffineTransformMakeScale(1.0, 1.0);
    target.backgroundColor = [UIColor orangeColor];
}

- (BOOL)shouldAnimateDroppableViewBack:(JDDroppableView*)view wasDroppedOnTarget:(UIView*)target
{
//    NSLog(@"shouldAnimateDroppableViewBack:wasDroppedOnTarget: %@", target == self.dropTarget1 ? @"one" : @"two");
    
	[self droppableView:view leftTarget:target];
    
    if (target == self.dropTarget1) {
        return YES;
    }
    
    // animate out and remove view
    [UIView animateWithDuration:0.33 animations:^{
        view.transform = CGAffineTransformMakeScale(0.2, 0.2);
        view.alpha = 0.2;
        view.center = target.center;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
    
    // update layout
    [self relayout];
    [self.scrollView flashScrollIndicators];
    
    return NO;
}

@end
