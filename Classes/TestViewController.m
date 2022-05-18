//
//  TestViewController.m
//  DroppableViewTest
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright Markus Emrich 2010. All rights reserved.
//

#import "TestViewController.h"
#import "JDDroppableView.h"

#import <CoreGraphics/CoreGraphics.h>

const CGFloat TestViewControllerViewMargin = 5.0;
const CGFloat TestViewControllerTargetViewSize = 34.0;

@interface TestViewController () <JDDroppableViewDelegate>
@property (nonatomic, assign) CGSize cardSize;
@property (nonatomic, assign) NSInteger cardsPerRow;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *button;
@property (nonatomic, strong) UIView *dropTarget1;
@property (nonatomic, strong) UIView *dropTarget2;
@property (nonatomic, assign) CGPoint lastPosition;
@property (nonatomic, assign) UIColor *previousBackgroundColor;
@end

@implementation TestViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        BOOL isIpad = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        self.cardsPerRow = isIpad ? 6 : 4;
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    // add button
    UIButton* button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [button setTitle: @"+" forState: UIControlStateNormal];
    [button addTarget: self action: @selector(addView:) forControlEvents: UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithRed:0.22 green:0.6 blue:0.33 alpha: 1.0];
    button.layer.cornerRadius = 5.0;
    button.showsTouchWhenHighlighted = YES;
    button.adjustsImageWhenHighlighted = YES;
    [self.view addSubview: button];
    self.button = button;
	
	// drop target 1
	self.dropTarget1 = [[UIView alloc] init];
    self.dropTarget1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	self.dropTarget1.backgroundColor = [UIColor darkGrayColor];
    self.dropTarget1.layer.cornerRadius = TestViewControllerTargetViewSize / 2.0;
    self.dropTarget1.frame = CGRectMake(0, 0, TestViewControllerTargetViewSize, TestViewControllerTargetViewSize);
	[self.view addSubview: self.dropTarget1];
	
	// drop target 2
	self.dropTarget2 = [[UIView alloc] init];
    self.dropTarget2.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	self.dropTarget2.backgroundColor = [UIColor redColor];
    self.dropTarget2.layer.cornerRadius = TestViewControllerTargetViewSize / 2.0;
    self.dropTarget2.frame = CGRectMake(0, 0, TestViewControllerTargetViewSize, TestViewControllerTargetViewSize);
	[self.view addSubview: self.dropTarget2];
	
	// scrollview
	self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.backgroundColor = [UIColor colorWithWhite:0.77 alpha:1.0];
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollView.contentInset = UIEdgeInsetsMake(6, 6, 6, 6);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    self.scrollView.layer.cornerRadius = 5.0;
    self.scrollView.userInteractionEnabled = NO;
	self.scrollView.canCancelContentTouches = NO;
	[self.view addSubview: self.scrollView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // calculate card size
    CGFloat contentWidth  = self.scrollView.frame.size.width  - self.scrollView.contentInset.left - self.scrollView.contentInset.right;
    CGFloat width = ((contentWidth-TestViewControllerViewMargin*(self.cardsPerRow-1))/self.cardsPerRow);
    self.cardSize = CGSizeMake(width,floor(width/10*18));

    // animate some draggable views in
    NSInteger rowCount = ceil(self.scrollView.frame.size.height/self.cardSize.height);
    NSInteger numberOfViews = self.cardsPerRow * rowCount - 2;
    CGFloat animationTimePerView = 0.15;
    for (int i = 0; i < numberOfViews; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i*animationTimePerView * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addView:nil];
            if (i%self.cardsPerRow==0) {
                [self scrollToBottomAnimated:YES];
            }
        });
    }

    // reenable userinteraction after animation ended
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(numberOfViews*animationTimePerView * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollView.userInteractionEnabled = YES;
    });
}

#pragma layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    const CGFloat topInset = self.view.safeAreaInsets.top + 20.0;
    const CGFloat bottomInset = self.view.safeAreaInsets.bottom + 20.0;

    self.button.frame = CGRectMake(20,
                                   self.view.frame.size.height - bottomInset - 44,
                                   self.view.frame.size.width - 40, // width
                                   44); // height

    self.dropTarget1.center = CGPointMake(self.view.frame.size.width/2 - 50, self.button.frame.origin.y - 35);
    self.dropTarget2.center = CGPointMake(self.view.frame.size.width/2 + 50, self.button.frame.origin.y - 35);

    self.scrollView.frame = CGRectMake(20,
                                       topInset,
                                       self.view.frame.size.width - 40,
                                       self.dropTarget1.center.y - topInset - 30);
}

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
	
    // iterate through all cards
    NSArray *cards = [self.scrollView.subviews filteredArrayUsingPredicate:
                      [NSPredicate predicateWithFormat:@"self.class == %@" argumentArray:@[[JDDroppableView class]]]];
    cards = [cards sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
    
	for (UIView* card in cards)
    {
        // create new position
		frame = card.frame;
        frame.origin.x = posx;
        frame.origin.y = posy;
        
        // update frame (if it did change)
        if (frame.origin.x != card.frame.origin.x ||
            frame.origin.y != card.frame.origin.y) {
            card.frame = frame;
        }
        
        // save last position
        self.lastPosition = CGPointMake(posx, posy);
		
        // add size and margin
		posx += frame.size.width + TestViewControllerViewMargin;
		
        // goto next row if needed
		if (posx > self.scrollView.frame.size.width - self.scrollView.contentInset.left - self.scrollView.contentInset.right)
        {
			posx = 0;
			posy += frame.size.height + TestViewControllerViewMargin;
		}
	}
    
    // fix last posy for correct contentSize
    if (posx != 0) {
        posy += frame.size.height;
    } else {
        posy -= TestViewControllerViewMargin;
    }
    
    // update content size
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, posy);
    
	[UIView commitAnimations];
}

- (void)addView:(id)sender
{
    static NSInteger viewCount = 0;
    
    JDDroppableView * dropview = [[JDDroppableView alloc] initWithDropTarget: self.dropTarget1];
    [dropview addDropTarget:self.dropTarget2];
    dropview.backgroundColor = [UIColor whiteColor];
    dropview.layer.cornerRadius = 3.0;
    dropview.frame = CGRectMake(self.lastPosition.x, self.lastPosition.y, self.cardSize.width, self.cardSize.height);
    dropview.delegate = self;
    dropview.tag = viewCount++;
    
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
    self.previousBackgroundColor = view.backgroundColor;
	[UIView animateWithDuration:0.33 animations:^{
        view.backgroundColor = [UIColor orangeColor];
        view.alpha = 0.8;
    }];
}

- (void)droppableViewDidMove:(JDDroppableView*)view;
{
    //
}

- (void)droppableViewEndedDragging:(JDDroppableView*)view onTarget:(UIView *)target
{
    if (target == self.dropTarget2) {
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
    } else {
        [UIView animateWithDuration:0.33 animations:^{
            if (!target) {
                view.backgroundColor = self.previousBackgroundColor;
            } else {
                view.backgroundColor = [UIColor darkGrayColor];
            }
            view.alpha = 1.0;
        }];
    }

}

- (void)droppableView:(JDDroppableView*)view enteredTarget:(UIView*)target
{
    [UIView animateWithDuration:0.1 animations:^{
        target.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }];
}

- (void)droppableView:(JDDroppableView*)view leftTarget:(UIView*)target
{
    [UIView animateWithDuration:0.1 animations:^{
        target.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (BOOL)shouldAnimateDroppableViewBack:(JDDroppableView*)view wasDroppedOnTarget:(UIView*)target
{
	[self droppableView:view leftTarget:target];
    
    if (target == self.dropTarget1) {
        return YES;
    }
    
    return NO;
}

@end
