DroppableView
---------------

A `DroppableView` represents a single draggable View. You may use it as a base class for the views, that you need to be draggable in your project. Currently it is built, to be used within a scrollView. But this could easily be changed.

The demo app demonstrates, how the `DroppableView` may be used in a project.
The `DroppableView` is used as a subview of a `UIScrollView` and can be dragged within and also out of the scrollview.

### Usage

Initalize the DroppableView like in th following example:  

- `aScrollView` is the parent scrollView
- `target` is a view outside of the scrollview, to where the element should be dragged.

`- (id) initWithScrollView: (UIScrollView *) aScrollView andDropTarget: (UIView *) target;`

and add it as a subview to your `UIScrollView`.  
**Note**: Your `UIScrollView` needs to set `canCancelContentTouches = NO;`.

### Screenshot of the example app:

The black cards can be dragged from the red scrollView onto the green circle.  
Try it!

  
![Screenshot](http://www.bilderload.com/bild/189325/droppableviewIRGWX.png)