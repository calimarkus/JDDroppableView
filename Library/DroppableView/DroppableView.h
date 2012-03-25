//
//  DroppableView.h
//  DroppableViewTest
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//


@class DroppableView;

@protocol DroppableViewDelegate <NSObject>
@optional
- (void) droppableViewBeganDragging: (DroppableView*) view;
- (void) droppableView: (DroppableView*) view enteredTarget: (UIView*) target;
- (void) droppableView: (DroppableView*) view leftTarget: (UIView*) target;
- (BOOL) shouldAnimateDroppableViewBack: (DroppableView*) view wasDraggedOnTarget: (UIView*) target;
- (void) droppableViewEndedDragging: (DroppableView*) view;
@end


@interface DroppableView : UIView
{	
	UIView * mDropTarget;
	UIView * mOuterView;
	UIScrollView * mScrollView;
	
    BOOL mIsOverTarget;
	CGPoint mOriginalPosition;
    
    id<DroppableViewDelegate> mDelegate;
}

@property (nonatomic, assign) id<DroppableViewDelegate> delegate;

- (id) initWithScrollView: (UIScrollView *) aScrollView andDropTarget: (UIView *) target;

@end
