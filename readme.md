## DroppableView

Easy Drag & Drop - even within scrollviews! A base class to make any view draggable. Automatic drag target recognition.
 
![screenshots](https://user-images.githubusercontent.com/807039/169490230-66ced2bc-bfc2-4270-bd6d-21a9823a9f8c.png)

A `DroppableView` represents a single draggable View. Use it as a base class for any view that should be draggable. You can even use it to drag something out of a scrollview, as you can see in the example project. The white cards can be dragged out of the scrollView onto the gray & red circles. Try it!

You can define views as drop targets like those gray & red circles. You will then be informed, if a dragged view hits those targets, leaves them again or is released / dropped over a drop target.

### Usage

Subclass any view from `JDDroppableView` and you are ready to go. If you want to specify certain views as drop-targets, you can use any of the following APIs to do so:

```objc
    - (id)initWithDropTarget:(UIView *)target;
    - (void)addDropTarget:(UIView *)target;
    - (void)removeDropTarget:(UIView *)target;
    - (void)replaceDropTargets:(NSArray *)targets;
```

- `target` is a view (outside of the scrollview), to where the element should be draggable

If you use a DroppableView within a `UIScrollView`, you need to set `canCancelContentTouches = NO;` on the scrollView.
