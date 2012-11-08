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
static CGFloat   sCOUNT_OF_VIEWS_VERTICALLY   = 2.7;


@implementation TestViewController


- (void)loadView
{
	[super loadView];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    // increase viewcount on ipad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sCOUNT_OF_VIEWS_HORICONTALLY = 6;
        sCOUNT_OF_VIEWS_VERTICALLY   = 4.3;
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
	
	// drop target
	self.dropTarget = [[UIView alloc] init];
    self.dropTarget.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	self.dropTarget.backgroundColor = [UIColor orangeColor];
	self.dropTarget.frame = CGRectMake(0, 0, 30, 30);
	self.dropTarget.center = CGPointMake(self.view.frame.size.width/2, button.frame.origin.y - 50);
    self.dropTarget.layer.cornerRadius = 15;
	[self.view addSubview: self.dropTarget];
	
	// scrollview
	self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.backgroundColor = [UIColor colorWithRed: 0.75 green: 0.2 blue: 0 alpha: 1.0];
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 5, 5, 5);
	self.scrollView.contentInset = UIEdgeInsetsMake(6, 6, 6, 6);
    self.scrollView.layer.cornerRadius = 5.0;
	self.scrollView.frame = CGRectMake(20,20, self.view.frame.size.width - 40, self.dropTarget.center.y - 70);
    self.scrollView.userInteractionEnabled = NO;
	self.scrollView.canCancelContentTouches = NO;
    
	[self.view addSubview: self.scrollView];
	
	// animate some draggable views in
    int numberOfViews            = sCOUNT_OF_VIEWS_HORICONTALLY*floor(sCOUNT_OF_VIEWS_VERTICALLY) + 2;
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
    CGFloat contentWidth  = self.scrollView.frame.size.width  - self.scrollView.contentInset.left - self.scrollView.contentInset.right;
    CGFloat contentHeight = self.scrollView.frame.size.height - self.scrollView.contentInset.top;
	CGSize size = CGSizeMake(((contentWidth-sDROPVIEW_MARGIN*(sCOUNT_OF_VIEWS_HORICONTALLY-1))/sCOUNT_OF_VIEWS_HORICONTALLY),
                             floor((contentHeight-sDROPVIEW_MARGIN*(sCOUNT_OF_VIEWS_VERTICALLY-1))/sCOUNT_OF_VIEWS_VERTICALLY));
	
    JDDroppableView * dropview = [[JDDroppableView alloc] initWithDropTarget: self.dropTarget];
    dropview.backgroundColor = [UIColor blackColor];
    dropview.layer.cornerRadius = 3.0;
    dropview.frame = CGRectMake(self.lastPosition.x, self.lastPosition.y, size.width, size.height);
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

#pragma -
#pragma droppabe view delegate

- (BOOL) shouldAnimateDroppableViewBack: (JDDroppableView *)view wasDroppedOnTarget: (UIView *)target
{
	[self droppableView: view leftTarget: target];
    
    CGRect frame = view.frame;
    frame.size.width *= 0.3;
    frame.size.height *= 0.3;
    frame.origin.x += (view.frame.size.width-frame.size.width)/2;
    frame.origin.y += (view.frame.size.height-frame.size.height)/2;
    
    [UIView beginAnimations: @"drag" context: nil];
    [UIView setAnimationDelegate: view];
    [UIView setAnimationDidStopSelector: @selector(removeFromSuperview)];
    
    view.frame = frame;
    view.center = target.center;
    
    [UIView commitAnimations];
    
    [self relayout];
    [self.scrollView flashScrollIndicators];
    
    return NO;
}

- (void) droppableViewBeganDragging:(JDDroppableView *)view
{
	[UIView beginAnimations: @"drag" context: nil];
	view.backgroundColor = [UIColor colorWithRed: 1 green: 0.5 blue: 0 alpha: 1];
	view.alpha = 0.8;
	[UIView commitAnimations];
}

- (void) droppableView:(JDDroppableView *)view enteredTarget:(UIView *)target
{
    target.transform = CGAffineTransformMakeScale(1.5, 1.5);
    target.backgroundColor = [UIColor greenColor];
}

- (void) droppableView:(JDDroppableView *)view leftTarget:(UIView *)target
{
    target.transform = CGAffineTransformMakeScale(1.0, 1.0);
    target.backgroundColor = [UIColor orangeColor];
}

- (void) droppableViewEndedDragging:(JDDroppableView *)view
{
	[UIView beginAnimations: @"drag" context: nil];
	view.backgroundColor = [UIColor blackColor];
	view.alpha = 1.0;
	[UIView commitAnimations];
}

@end
