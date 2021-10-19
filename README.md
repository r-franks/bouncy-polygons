# bouncy-polygons
bouncy-polygons is an art engine that permits the creation of interesting and unique art pieces by offering control the physical properties of the artistic medium.
When a polygon is drawn to the canvas of bouncy-polygons, it is not merely an inert image but rather live object, capable of moving, leaving trails, and interacting with other polygons on its own.
This behavior (defined by user-controlled parameters like gravitational attractive force, down-force, coefficient of restitution, trail persistence, and polygon persistence) can lead to unique and unpredictable art pieces.

The way people create art is often defined by the behavior of the artistic medium: different paints run in different ways, pencils and markers have different textures, etc.
In turn, the the artistic medium is defined by its physical properties. 
In digital spaces, we can create materials with arbitrary physical properties outside the limitations of the real world -- creating a broad spectrum of interesting media and resultant art. 
This is the motivation behind bouncy-polygons.

## The User-Interface
The below diagram serves as both a summary of the bouncy-polygon UI and a demonstration of what one can do by playing around with it.
Note that while the range of options afforded by this program is intimidating, they don't need to be memorized. 
While the program is running, simply mouse-over any bar or button on the UI and a text box will describe its functionality/what it controls. 
<img src="https://github.com/russchertow/bouncy-polygons/blob/main/annotated_ui_example_photo.png" height=100% width=100%>

### Top Left Buttons: Canvas Controls
* Left-most Button (blue): Saves the canvas as an image
* Second-to-left Button (dark green): Toggles how polygons are added to canvas
  - Individual Add Mode: Press the left mouse button down and drag outward -- the direction that the mouse is dragged and its distance from its original position will define the size and orientation of the created polygon
  - Bulk Add Mode: Left-click on the canvas -- polygons will be continuously added as long as the left mouse button is pressed down
* Third-to-left Button (lime/green-yellow): Toggles whether polygons will make noise when they collide with each-other or line segments. 
Sounds produced depend on the color and size of the polygons colliding.
* Fourth-to-left Button (red): Clears the screen of any trails left by polygons (does not delete polygons from the canvas)

### Left Panel: Polygon Initialization/Structure Controls
These bars control
* Left Bar: Magnitude of initial translational velocity (direction determined randomly) 
* Right Bar: Initial angular velocity (green/above-bar-center implies counter-clockwise, purple/below-bar-center implies clockwise)
* Top Square: Polygon size and initial orientation
  - This is used when one wants to create many polygons en-masse rather than defining each individually. 

### Right Panel: Polygon Appearance Controls

### Bottom Panel: Physics Controls



