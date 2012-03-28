//
//  TestViewController.m
//  DroppableViewTest
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright Markus Emrich 2010. All rights reserved.
//

#import "TestViewController.h"
#import "DroppableView.h"

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
    [button setTitle: @"+" forState: UIControlStateNormal];
    [button addTarget: self action: @selector(addView:) forControlEvents: UIControlEventTouchUpInside];
    button.frame = CGRectMake(20, 0, self.view.frameWidth - 40, 32);
    button.backgroundColor = [UIColor colorWithRed: 0.75 green: 0.2 blue: 0 alpha: 1.0];
    button.layer.cornerRadius = 5.0;
    button.showsTouchWhenHighlighted = YES;
    button.adjustsImageWhenHighlighted = YES;
    button.frameBottom = self.view.frameBottom - 40;
    [self.view addSubview: button];
	
	// drop target
	mDropTarget = [[UIView alloc] init];
	mDropTarget.backgroundColor = [UIColor orangeColor];
	mDropTarget.frame = CGRectMake(0, 0, 30, 30);
	mDropTarget.center = CGPointMake(self.view.frameWidth/2, button.frameY - 50);
    mDropTarget.layer.cornerRadius = 15;
	[self.view addSubview: mDropTarget];
    [mDropTarget release];
	
	// scrollview
	mScrollView = [[UIScrollView alloc] init];
	mScrollView.backgroundColor = [UIColor colorWithRed: 0.75 green: 0.2 blue: 0 alpha: 1.0];
	mScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	mScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 5, 5, 5);
	mScrollView.contentInset = UIEdgeInsetsMake(6, 6, 6, 6);
    mScrollView.layer.cornerRadius = 5.0;
	mScrollView.frame = CGRectMake(20,20, self.view.frameWidth - 40, mDropTarget.centerY - 70);
    mScrollView.userInteractionEnabled = NO;
	mScrollView.canCancelContentTouches = NO;
    
	[self.view addSubview: mScrollView];
    [mScrollView release];
	
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
    [mScrollView performSelector: @selector(setUserInteractionEnabled:) withObject: [NSNumber numberWithBool: YES] afterDelay: numberOfViews*animationTimePerView];
}

#pragma layout

- (void) relayout
{
    // cancel all animations
    [mScrollView.layer removeAllAnimations];
	for (UIView* subview in mScrollView.subviews)
        [subview.layer removeAllAnimations];
    
    // setup new animation
	[UIView beginAnimations: @"drag" context: nil];
    
    // init calculation vars
	float posx = 0;
	float posy = 0;
	CGRect frame = CGRectZero;
    mLastPosition = CGPointMake(0, -100);
    CGFloat contentWidth = mScrollView.contentSize.width - mScrollView.contentInset.left - mScrollView.contentInset.right;
	
    // iterate through all subviews
	for (UIView* subview in mScrollView.subviews)
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
        mLastPosition = CGPointMake(posx, posy);
		
        // add size and margin
		posx += frame.size.width + sDROPVIEW_MARGIN;
		
        // goto next row if needed
		if (posx > mScrollView.frame.size.width - mScrollView.contentInset.left - mScrollView.contentInset.right)
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
    mScrollView.contentSize = CGSizeMake(contentWidth, posy);
    
	[UIView commitAnimations];
}

- (void) addView: (id) sender
{
    CGFloat contentWidth  = mScrollView.frame.size.width  - mScrollView.contentInset.left - mScrollView.contentInset.right;
    CGFloat contentHeight = mScrollView.frame.size.height - mScrollView.contentInset.top;
	CGSize size = CGSizeMake(((contentWidth-sDROPVIEW_MARGIN*(sCOUNT_OF_VIEWS_HORICONTALLY-1))/sCOUNT_OF_VIEWS_HORICONTALLY),
                             floor((contentHeight-sDROPVIEW_MARGIN*(sCOUNT_OF_VIEWS_VERTICALLY-1))/sCOUNT_OF_VIEWS_VERTICALLY));
	
    DroppableView * dropview = [[DroppableView alloc] initWithScrollView: mScrollView
                                                           andDropTarget: mDropTarget];
    dropview.backgroundColor = [UIColor blackColor];
    dropview.layer.cornerRadius = 3.0;
    dropview.frame = CGRectMake(mLastPosition.x, mLastPosition.y, size.width, size.height);
    dropview.delegate = self;
    
    [mScrollView addSubview: dropview];
    [dropview release];
    
    [self relayout];
    
    // scroll to bottom, if added manually
    if ([sender isKindOfClass: [UIButton class]]) {
        [self scrollToBottomAnimated: YES];
    }
}

- (void) scrollToBottomAnimated: (BOOL) animated
{
    [mScrollView.layer removeAllAnimations];
    
    CGFloat bottomScrollPosition = mScrollView.contentSize.height;
    bottomScrollPosition -= mScrollView.frame.size.height;
    bottomScrollPosition += mScrollView.contentInset.top;
    bottomScrollPosition = MAX(-mScrollView.contentInset.top,bottomScrollPosition);
    CGPoint newOffset = CGPointMake(-mScrollView.contentInset.left, bottomScrollPosition);
    if (newOffset.y != mScrollView.contentOffset.y) {
        [mScrollView setContentOffset: newOffset animated: animated];
    }
}

#pragma -
#pragma droppabe view delegate

- (BOOL) shouldAnimateDroppableViewBack: (DroppableView *)view wasDroppedOnTarget: (UIView *)target
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
    [mScrollView flashScrollIndicators];
    
    return NO;
}

- (void) droppableViewBeganDragging:(DroppableView *)view
{
	[UIView beginAnimations: @"drag" context: nil];
	view.backgroundColor = [UIColor colorWithRed: 1 green: 0.5 blue: 0 alpha: 1];
	view.alpha = 0.8;
	[UIView commitAnimations];
}

- (void) droppableView:(DroppableView *)view enteredTarget:(UIView *)target
{
    target.transform = CGAffineTransformMakeScale(1.5, 1.5);
    target.backgroundColor = [UIColor greenColor];
}

- (void) droppableView:(DroppableView *)view leftTarget:(UIView *)target
{
    target.transform = CGAffineTransformMakeScale(1.0, 1.0);
    target.backgroundColor = [UIColor orangeColor];
}

- (void) droppableViewEndedDragging:(DroppableView *)view
{
	[UIView beginAnimations: @"drag" context: nil];
	view.backgroundColor = [UIColor blackColor];
	view.alpha = 1.0;
	[UIView commitAnimations];
}

@end
