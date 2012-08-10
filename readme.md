DroppableView
---------------

A `DroppableView` represents a single draggable View. You may use it as a base class for any view, that you need to be draggable in your project. You can even use it to drag something out of a scrollview, as you can seen in the example project.

The demo app demonstrates, how the `DroppableView` may be used in a project.
The `DroppableView` is used as a subview of a `UIScrollView` and can be dragged within and also out of the scrollview.

### Usage

Initalize the DroppableView like in th following example:  

`- (id) initWithDropTarget: (UIView *) target;`

- `target` is a view (outside of the scrollview), to where the element should be dragged.

If tou do use a DroppableView within a `UIScrollView`, you need to set `canCancelContentTouches = NO;` on the scrollView.

### Screenshot of the example app:

The black cards can be dragged from the red scrollView onto the green circle.  
Try it!

  
![Screenshot](http://www.bilderload.com/bild/189325/droppableviewIRGWX.png)