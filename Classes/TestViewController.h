//
//  TestViewController.h
//  DroppableViewTest
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright Markus Emrich 2010. All rights reserved.
//

#import "JDDroppableView.h"

@interface TestViewController : UIViewController <JDDroppableViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *dropTarget1;
@property (nonatomic, strong) UIView *dropTarget2;
@property (nonatomic, assign) CGPoint lastPosition;

- (void)relayout;
- (void)addView:(id)sender;
- (void)scrollToBottomAnimated:(BOOL)animated;

@end

