This demo app demonstrates, how the `DroppableView` may be used in a project.
The `DroppableView` is used as a subview of a scrollView, which can be dragged within and also to the outside of the scrollview.

Initalize it using the following method. Where `aScrollView` is the parent scrollView and `target` is a view outside of the scrollview, to where the element can be dragged.

`- (id) initWithScrollView: (UIScrollView *) aScrollView andDropTarget: (UIView *) target;`

and add it to your `UIScrollView`. <br>
**Note**: Your `UIScrollView` needs to set `canCancelContentTouches = NO;`.

Screenshot der Beispiel App:

![Screenshot](http://www.bilderload.com/bild/189325/droppableviewIRGWX.png)