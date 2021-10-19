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

### Basic UI Controls
#### Creating Polygons
In Individual Add Mode, press the left mouse button and drag to create a polygon and define its size. In Bulk Add Mode, just press the left mouse button. Toggling between Individual Add Mode and Bulk Add Mode can be achieved by clicking on the second-to-the-left-most button (blue-green) at the top of the window. 

#### Creating Line Segments
Press the right mouse button to define the first end-point of the line segment. Then, while pressed, drag the cursor to the desired second end-point of the line segment and release.

#### Deleting Entities
When <code>shift</code>+<code>right click</code> is down, a white circle will appear under the cursor. When this white circle overlaps with any polygon or line segment, that polygon or line segment is deleted. This allows one to individually removed particular polygons or line segments.

All polygons or all line-segments can also be deleted using the UI controls. The top-center-left button (magenta) deletes all polygons and the top-center-right button (orange) next to it deletes all line segments.

### Top Left Buttons: Canvas Controls
* Left-most Button (blue): Saves the canvas as an image
* Second-to-left Button (blue-green): Toggles how polygons are added to canvas
  - Individual Add Mode: Press the left mouse button down and drag outward -- the direction that the mouse is dragged and its distance from its original position will define the size and orientation of the created polygon
  - Bulk Add Mode: Left-click on the canvas -- polygons will be continuously added as long as the left mouse button is pressed down
* Third-to-left Button (lime/green-yellow): Toggles whether polygons will make noise when they collide with each-other or line segments. 
Sounds produced depend on the color and size of the polygons colliding.
* Fourth-to-left Button (red): Clears the screen of any trails left by polygons (does not delete polygons from the canvas)

### Top Panel: Miscellaneous
* Top Left Buttons (many colors): Determines which type of polygons will be added to the screen. When a polygon is added, its shape is randomly selected from the shapes associated with active buttons.
* Top Center Left Button (pink/purple): Deletes all polygons when pressed, but does not clear the screen of trails. <code>backspace</code> serves the same purpose.
* Top Center Right Button (orange): Deletes all line segments when pressed, but does not clear the screen
* Top Right Horizontal Bar (purple): Defines strength of downforce. When empty, particles are effectively floating in space, only attracted by each other.
* Top Right Button (beige/brown): Activates smudge mode

### Left Panel: Polygon Initialization/Structure Controls
These bars control how polygon parameters relevent to physics simulation are initialized:
* Left Bar: Magnitude of initial translational velocity (direction determined randomly) 
* Right Bar: Initial angular velocity (green/above-bar-center implies counter-clockwise, purple/below-bar-center implies clockwise)
* Top Square: Polygon size and initial orientation
  - This is used when one wants to create many polygons en-masse rather than defining each individually. 

### Right Panel: Polygon Appearance Controls
Loosely speaking, these bars control how polygons are drawn and polygon appearance upon initialization:
* Third-right-most Bar (salmon): The length of the velocity vector, as displayed visually. Velocity vectors are drawn as black lines starting at each polygon's center of mass. 
When the bar is empty, no velocity vector is drawn.
* Second-right-most Bar (yellow): The amount of time that a polygon's trail remains on the canvas before fading out. When the bar is empty, polygons leave no trail. When the bar is filled, the trail left by a polygon never fades out (until the parameter is changed or the screen is cleared manually).
* Right-most Bar (orange): The amount of time that the polygon spends active before fading out. When the bar is empty, polygons fade out almost immediately. When the bar is filled, polygons are on screen permanently (until the parameter is changed or the polygon is cleared manually).
* Polygon Toggle Buttons: How polygons are drawn. From left to right:
  - Full Color Fill
  - Perimeter Color, White Fill
  - Perimeter Color, No Fill
  - Invisible
* Color Square: Click in the color squared and drag to create a rectangle. When polygons are created, they are assigned colors randomly selected from the colors within the rectangle.

### Bottom Panel: Physics Controls
These parameters control how polygons move:
* Top Bar (blue): Defines the coefficient of restitution (percent of relative speed retained between two objects after collision). When the bar is filled, no velocity along the body-to-collision-point vector is lost. When it is empty, all energy in this direction is lost. In practice, reducing coefficient of restitution causes bodies to orbit/spin-around-eachother as only velocity tangential to the vector to centrer of mass winds up being retained
* Second-to-top Bar (purple): Defines the coefficient of friction. When the bar is filled, velocity tangential to body-to-collision-point vector is lost. When empty, no velocity is lost. If planet formation is desired, this force needs to be reasonable strong to prevent particles from simply spinning around each other.
* Third-to-top Bar (magenta): Strength of gravitation attraction between polygons.
* Bottom Bar (maroon): Integration time-step. The lower it is, the more accurate and slower the rigid body simulation is. The higher it is, the faster and less accurate the simulation is.





