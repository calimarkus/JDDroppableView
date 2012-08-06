//
//  JDDroppableView.h
//  JDDroppableView
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//


@class JDDroppableView;

@protocol JDDroppableViewDelegate <NSObject>
@optional
- (void) droppableViewBeganDragging: (JDDroppableView*) view;
- (void) droppableView: (JDDroppableView*) view enteredTarget: (UIView*) target;
- (void) droppableView: (JDDroppableView*) view leftTarget: (UIView*) target;
- (BOOL) shouldAnimateDroppableViewBack: (JDDroppableView*) view wasDroppedOnTarget: (UIView*) target;
- (void) droppableViewEndedDragging: (JDDroppableView*) view;
@end


@interface JDDroppableView : UIView
{	
	UIView * mDropTarget;
	UIView * mOuterView;
	UIScrollView * mScrollView;
	
    BOOL mIsOverTarget;
	CGPoint mOriginalPosition;
    
    id<JDDroppableViewDelegate> mDelegate;
}

@property (nonatomic, assign) id<JDDroppableViewDelegate> delegate;

- (id) initWithScrollView: (UIScrollView *) aScrollView andDropTarget: (UIView *) target;

@end
