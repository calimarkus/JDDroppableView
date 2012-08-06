//
//  TestViewController.h
//  DroppableViewTest
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright Markus Emrich 2010. All rights reserved.
//

#import "JDDroppableView.h"

@interface TestViewController : UIViewController <JDDroppableViewDelegate>
{
    UIScrollView* mScrollView;
    UIView* mDropTarget;
    
    CGPoint mLastPosition;
}

- (void) relayout;
- (void) addView: (id) sender;
- (void) scrollToBottomAnimated: (BOOL) animated;

@end

