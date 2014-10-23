## DroppableView

A `DroppableView` represents a single draggable View. You may use it as a base class for any view, that you need to be draggable in your project. You can even use it to drag something out of a scrollview, as you can see in the example project: The white cards can be dragged out of the scrollView onto the gray & red circles. Try it!
 
![Screenshot](screenshots.png)

### Usage

Just subclass from `JDDroppableView` and your ready to go. If you want to use specific drop-targets, you can use any of the following APIs to add them:

    - (id)initWithDropTarget:(UIView*)target;
    - (void)addDropTarget:(UIView*)target;
    - (void)removeDropTarget:(UIView*)target;
    - (void)replaceDropTargets:(NSArray*)targets;

- `target` is a view (outside of the scrollview), to where the element should be draggable

**NOTE:** If you use a DroppableView within a `UIScrollView`, you need to set `canCancelContentTouches = NO;` on the scrollView.



