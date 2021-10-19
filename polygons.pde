//artistic rigid body physics engine
//code by ryan franks
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.UIManager.LookAndFeelInfo;
import java.lang.Math;

//size of screen
Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();

final int screenWidth=(int)(.9*screenSize.getWidth());
final int screenHeight=(int)(.9*screenSize.getHeight());
final int BorderLength=(int)(.2*min(screenWidth, screenHeight));

final int xmin=BorderLength;
final int xmax=screenWidth-BorderLength;
final int ymin=(int)(BorderLength*.25);
final int ymax=screenHeight-BorderLength;
final int Width=xmax-xmin;
final int Height=ymax-ymin;
final int Area=min(Width, Height)*min(Width, Height);

final int TopBorderLength=(int)(Width/30);

PImage ColorWheel;

PGraphics ActiveZone;

int PolygonsCreated=0;

int a = 500;

void settings() {
  size(screenWidth, screenHeight, P2D);
}

void setup() {  
  ColorWheel=loadImage("ColorWheel3.jpg");
  ColorWheel.resize((int)BorderLength, (int)BorderLength);
  
  DisplayPolygon=new Polygon(ShapeCenter.x, ShapeCenter.y, angle, new PVector(0, 0), 0, radius, 3, color(200, 150, 220), 0);  

  ActiveZone=createGraphics(Width, Height);
  ActiveZone.beginDraw();
  ActiveZone.background(255);
  ActiveZone.endDraw();

  Buttons.add(new Button(0, 0, .25*BorderLength, .25*BorderLength, color(100, 100, 200), "Save")); //0
  Buttons.add(new Button(.25*BorderLength, 0, .25*BorderLength, .25*BorderLength, color(100, 255, 200), "Toggle Mode")); //1
  Buttons.add(new Button(.5*BorderLength, 0, .25*BorderLength, .25*BorderLength, color(200, 255, 100), "Sound")); //2 
  Buttons.add(new Button(.75*BorderLength, 0, .25*BorderLength, .25*BorderLength, color(200, 100, 100), "Clear Screen")); //3

  Buttons.add(new Button(screenWidth-BorderLength-TopBorderLength, 0, TopBorderLength, TopBorderLength, color(200, 150, 100), "Smudge Mode")); //4

  Bars.add(new Bar(0, 1.25*BorderLength, .5*BorderLength, screenHeight-1.25*BorderLength, 0, 20, color(200, 255, 200), color(0), "Translational Velocity")); //0
  Bars.add(new SplitVerticalBar(.5*BorderLength, 1.25*BorderLength, .5*BorderLength, screenHeight-1.25*BorderLength, PI/2, color(0, 255, 100), color(0), "Rotational Velocity")); //1
  Bars.add(new HorizontalBar(BorderLength, screenHeight-BorderLength, screenWidth-2*BorderLength, BorderLength/6, 0, 1, color(100, 100, 255), color(0), "Coefficient of Restitution")); //2
  Bars.get(2).measure=1;
  Bars.add(new HorizontalBar(BorderLength, screenHeight-5*BorderLength/6, screenWidth-2*BorderLength, BorderLength/6, 0, 1, color(150, 100, 255), color(0), "Coefficient of Friction")); //3
  Bars.get(3).measure=0;
  Bars.add(new HorizontalBar(BorderLength, screenHeight-2*BorderLength/3, Width, BorderLength/3, 0, 1, color(200, 100, 255), color(0), "Gravitational Constant")); //4
  Bars.add(new HorizontalBar(BorderLength, screenHeight-BorderLength/3, Width, BorderLength/3, 0, 1, color(200, 75, 100), color(0), "Time-Step")); //5

  ArrayList<Button>ColorOptions=new ArrayList<Button>();
  ColorOptions.add(new PolygonButton1(screenWidth-BorderLength, BorderLength, BorderLength/4, BorderLength/4, color(200, 100, 50), color(200, 100, 50), color(200, 200, 200), 5, "Color Fill")); //0 
  ColorOptions.add(new PolygonButton1(screenWidth-BorderLength+BorderLength/4, BorderLength, BorderLength/4, BorderLength/4, color(200, 100, 50), color(255, 255, 255), color(200, 200, 200), 5, "White Fill")); //1
  ColorOptions.add(new PolygonButton1(screenWidth-BorderLength+2*BorderLength/4, BorderLength, BorderLength/4, BorderLength/4, color(200, 100, 50), color(200, 200, 200), color(200, 200, 200), 5, "Empty Fill")); //2
  ColorOptions.add(new PolygonButton1(screenWidth-BorderLength+3*BorderLength/4, BorderLength, BorderLength/4, BorderLength/4, color(200, 200, 200), color(200, 200, 200), color(200, 200, 200), 5, "Invisible")); //3
  ColorChoices=new ButtonToggler(ColorOptions);

  Buttons.add(new PolygonButton2(BorderLength, 0, TopBorderLength, TopBorderLength, color(255, 0, 127), 3, "Triangle")); //5
  Buttons.add(new PolygonButton2(BorderLength+TopBorderLength, 0, TopBorderLength, TopBorderLength, color(255, 0, 255), 4, "Square")); //6
  Buttons.add(new PolygonButton2(BorderLength+2*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(127, 0, 255), 5, "Pentagon")); //7
  Buttons.add(new PolygonButton2(BorderLength+3*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(0, 0, 255), 6, "Hexagon")); //8
  Buttons.add(new PolygonButton2(BorderLength+4*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(0, 127, 255), 7, "Heptagon")); //9
  Buttons.add(new PolygonButton2(BorderLength+5*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(0, 255, 255), 8, "Octagon")); //10
  Buttons.add(new PolygonButton2(BorderLength+6*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(0, 255, 127), 9, "Nonagon")); //11
  Buttons.add(new PolygonButton2(BorderLength+7*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(0, 255, 0), 10, "Decagon")); //12
  Buttons.add(new PolygonButton2(BorderLength+8*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(127, 255, 0), 11, "Dodecagon")); //13
  Buttons.add(new PolygonButton2(BorderLength+9*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(255, 255, 0), 12, "Pendedecagon")); //14
  Buttons.add(new PolygonButton2(BorderLength+10*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(255, 127, 0), 20, "Icosagon")); //15
  Buttons.add(new PolygonButton2(BorderLength+11*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(255, 0, 0), 50, "Pentacontagon")); //16

  Buttons.add(new Button(BorderLength+13*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(255, 0, 150), "Clear Polygons")); //17
  Buttons.add(new Button(BorderLength+14*TopBorderLength, 0, TopBorderLength, TopBorderLength, color(255, 150, 0), "Clear Segments"));//18

  Bars.add(new FloorBar(screenWidth-BorderLength, 5*BorderLength/4, BorderLength/3, screenHeight-5/4*BorderLength, 0, 10, color(220, 125, 100), color(0), "Tail Length")); //6
  Bars.add(new Bar(screenWidth-2*BorderLength/3, 5*BorderLength/4, BorderLength/3, screenHeight-5/4*BorderLength, 0, 255, color(200, 255, 100), color(0), "Trail Persistence"));  //7
  Bars.add(new Bar(screenWidth-BorderLength/3, 5*BorderLength/4, BorderLength/3, screenHeight-5/4*BorderLength, 0, 255, color(255, 130, 50), color(0), "Polygon Persistence")); //8
  Bars.get(8).measure=255;

  Bars.add(new HorizontalBar(BorderLength+16*TopBorderLength, 0, 12*TopBorderLength, TopBorderLength, 0, 1, color(200, 100, 255), color(0), "Gravitational Acceleration")); //9
}

void draw() {
  ActiveZone.beginDraw();
  ActiveZone.fill(255, 255, 255, 255-Bars.get(7).measure);
  ActiveZone.noStroke();
  ActiveZone.rect(0, 0, screenWidth, screenHeight);
  ArrayList<Polygon>PrevPolygons=new ArrayList<Polygon>();
  PrevPolygons.addAll(Polygons);
  moveAll();
  for (Polygon a : PrevPolygons) {
    Polygon p=Polygons.get(PrevPolygons.indexOf(a)); 
    a.V=PVector.add(PVector.mult(p.prevV, 0.5), PVector.mult(p.V, 0.5));
  }  
  Polygons.clear();
  Polygons.addAll(PrevPolygons);
  collideAll();
  ArrayList<Polygon>InvisiblePolygons=new ArrayList<Polygon>();
  for (Polygon p : Polygons) {
    if (alpha(p.Color)<=0) {
      InvisiblePolygons.add(p);
    }
  }
  for (Polygon p : InvisiblePolygons) {
    Polygons.remove(p);
  }  
  boolean showDeletionEllipse=false;
  if (keyPressed && mousePressed && mouseX>xmin && mouseX<xmax && mouseY>ymin && mouseY<ymax) {
    if (key==CODED) {
      if (keyCode==SHIFT) {
        PVector Mouse=new PVector(mouseX, mouseY);
        if (mouseButton==LEFT) {
          Polygon Removable=null;
          for (Polygon a : Polygons) {
            if (a.pointInPolygon(Mouse)) {
              Removable=a;
            }
          } 
          if (Removable!=null) {
            Polygons.remove(Removable);
          }
        } else if (mouseButton==RIGHT) {
          showDeletionEllipse=true;
          Segment Removable=null;
          for (Segment a : Segments) {
            if (PVector.sub(closestPointOnLineSegment(a.v1, a.v2, Mouse), Mouse).magSq()<100) {
              Removable=a;
            }
          }
          if (Removable!=null) {
            Segments.remove(Removable);
          }
        }
      }
    }
  }
  displayOnActiveZone();
  createLine();
  if (!Buttons.get(1).active) {
    createPolygon();
  } else {
    updateSizeAndOrientation();
    addPolygon();
  }
  ActiveZone.endDraw();
  image(ActiveZone, xmin, ymin);
  if (showDeletionEllipse) {
    noFill();
    stroke(0);
    ellipse(mouseX, mouseY, 20, 20);
  }
  displayControls();
  if (pmouseX==mouseX && pmouseY==mouseY && !mousePressed) {
    showMouseOverText();
  }
}

void mouseClicked() {
  for (Button a : Buttons) {
    a.updateStatus();
  }
  if (Buttons.get(3).active) {
    Buttons.get(3).active=false;
    ActiveZone.beginDraw();
    ActiveZone.stroke(255, 255, 255);
    ActiveZone.fill(255, 255, 255);
    ActiveZone.rect(0, 0, Width, height);
    ActiveZone.endDraw();
  } else if (Buttons.get(0).active) {
    ActiveZone.save(minute()+"-"+hour()+"-"+day()+"-"+month()+"-"+year());
    Buttons.get(0).active=false;
  } else if (Buttons.get(17).active) {
    Buttons.get(17).active=false;
    Polygons.clear();
  } else if (Buttons.get(18).active) {
    Buttons.get(18).active=false;
    Segments.clear();
  }
  ColorChoices.updateStatus();
}

void keyPressed() {
  if (key==BACKSPACE) {
    Polygons.clear();
  }
}

void moveAll() {
  for (Polygon a : Polygons) {
    a.V.y+=Bars.get(5).measure*Bars.get(9).measure;
    for (Polygon b : Polygons) {
      a.applyGravity(b);
    }
  }
  for (Polygon a : Polygons) {
    a.move();
  }
}

void collideAll() {
  for (Polygon a : Polygons) {
    for (Polygon b : Polygons) {
      if (Polygons.indexOf(a)<Polygons.indexOf(b)) {
        a.collide(b);
      }
    }
  }
  for (Polygon a : Polygons) {
    for (Segment b : Segments) {
      a.collide(b);
    }
    a.checkWalls();
  }
}

void displayOnActiveZone() {
  for (Polygon a : Polygons) {
    a.display();
  }
  for (Segment a : Segments) {
    a.display();
  }
  if (Buttons.get(4).active) {
    smudgeScreen();
  }
}
void displayControls() {
  fill(255);
  noStroke();
  rect(BorderLength, 0, Width, BorderLength*.25);
  displaySizeAndOrientation();
  for (Bar a : Bars) {
    a.updateMeasure();
    a.display();
  }
  for (Button a : Buttons) {
    a.display();
  }
  ColorChoices.display();
  displayColorSelector();
}

PVector lockedX=new PVector(xmax, 0); 
PVector lockedNewX=new PVector(screenWidth, BorderLength);
boolean SquareLocked;
void adjustColorRange() {
  if (mousePressed && mouseX>=xmax && mouseY<=BorderLength && !SquareLocked) {    
    SquareLocked=true;
    lockedX=new PVector(mouseX, mouseY);
  }
  if (mousePressed && (mouseX>=xmax && mouseY<=BorderLength) && SquareLocked) {
    lockedNewX=new PVector(mouseX, mouseY);
  } else if (SquareLocked) {
    SquareLocked=false;
  }
}

void displayColorSelector() {
  adjustColorRange();
  image(ColorWheel, screenWidth-BorderLength, 0);
  stroke(0);
  noFill();
  rect(min(lockedX.x, lockedNewX.x), min(lockedX.y, lockedNewX.y), abs(lockedX.x-lockedNewX.x), abs(lockedX.y-lockedNewX.y));
}

color getColor() {
  PVector ColorX=new PVector(random(min(lockedX.x, lockedNewX.x), max(lockedX.x, lockedNewX.x)), random(min(lockedX.y, lockedNewX.y), max(lockedX.y, lockedNewX.y)));
  ColorX.sub(new PVector(xmax, 0));
  color c=ColorWheel.get((int)(ColorX.x), (int)(ColorX.y));
  return c;
}

boolean locked=false;
PVector lockedmouse, lockedV;
Polygon lockedP;
color lockedColor;
int lockedSideNumber=5;
int lockedID=0;
void createPolygon() {
  if (mousePressed && (mouseX>=xmin && mouseX<=xmax && mouseY>=ymin && mouseY<=ymax) && !locked && mouseButton==LEFT && !keyPressed) {
    locked=true;
    lockedmouse=new PVector(mouseX, mouseY);
    lockedV=PVector.random2D();  
    lockedV.mult(Bars.get(0).measure);  
    lockedColor=getColor();
    lockedSideNumber=biasedPolygonSelector();
    lockedID=PolygonsCreated;
    lockedP=new Polygon(lockedmouse.x, lockedmouse.y, 0, lockedV, Bars.get(1).measure, 0, lockedSideNumber, lockedColor, lockedID);
  }
  if (mousePressed && (mouseX>=xmin && mouseX<=xmax && mouseY>=ymin && mouseY<=ymax) && locked && mouseButton==LEFT && !keyPressed) {
    PVector X=new PVector(mouseX, mouseY);
    PVector dX=PVector.sub(lockedmouse, X);
    float angle=0;
    float dXmag=dX.mag();
    if (dXmag>0) {
      if (dX.y>0) {
        angle=acos(dX.x/dXmag);
      } else if (dX.y<=0) {
        angle=2*PI-acos(dX.x/dXmag);
      }
    }
    float size=dX.mag();
    PVector v=PVector.random2D();
    v.mult(Bars.get(0).measure);
    lockedP=new Polygon(lockedmouse.x, lockedmouse.y, angle, lockedV, Bars.get(1).measure, size, lockedSideNumber, lockedColor, lockedID);
    lockedP.display();
  } else if (locked) {
    if (mouseButton!=RIGHT) {
      if (lockedP.Circumradius>0) {
        Polygons.add(lockedP);
        PolygonsCreated+=1;
      }
    }
    locked=false;
  }
}

PVector ShapeCenter=new PVector(BorderLength/2, .25*BorderLength+BorderLength/2);
float radius=1;
float angle=0;
Polygon DisplayPolygon;

void updateSizeAndOrientation() {
  if (mousePressed) {
    PVector X=new PVector(mouseX, mouseY);
    PVector dX=PVector.sub(ShapeCenter, X);
    if (dX.magSq()<=.25*BorderLength*BorderLength) {
      radius=dX.mag();
      if (dX.y>0) {
        angle=acos(dX.x/radius);
      } else if (dX.y<=0) {
        angle=2*PI-acos(dX.x/radius);
      }
      DisplayPolygon=new Polygon(ShapeCenter.x, ShapeCenter.y, angle, new PVector(0, 0), 0, radius, 3, color(200, 150, 220), 0);
    }
  }
}

void addPolygon() {
  if (!keyPressed && mousePressed && mouseButton==LEFT && radius>0 && mouseX>xmin && mouseX<xmax && mouseY>ymin && mouseY<ymax) {
    PVector v=PVector.random2D();
    v.mult(Bars.get(0).measure);
    Polygon P=new Polygon(mouseX, mouseY, angle, v, Bars.get(1).measure, radius, biasedPolygonSelector(), getColor(), PolygonsCreated);
    Polygons.add(P);
    PolygonsCreated+=1;
  }
}

void displaySizeAndOrientation() {
  stroke(0);
  fill(0);
  rect(0, .25*BorderLength, BorderLength, BorderLength);
  stroke(255);
  fill(255);
  ellipse(ShapeCenter.x, ShapeCenter.y, BorderLength, BorderLength);
  fill(DisplayPolygon.Color);
  stroke(DisplayPolygon.Color);
  shape(DisplayPolygon.Shape, DisplayPolygon.X.x, DisplayPolygon.X.y);
  if (!Buttons.get(1).active) {
    stroke(100, 100, 100, 200);
    fill(100, 100, 100, 200);    
    rect(0, .25*BorderLength, BorderLength, BorderLength);
  }
}

int biasedPolygonSelector() { //randomly selects side number from pool of side numbers associated with pressed buttons
  ArrayList<Button> ActiveButtons=new ArrayList<Button>();
  for (Button a : Buttons) {
    if (a.active && a instanceof PolygonButton2) {
      ActiveButtons.add(a);
    }
  }
  if (ActiveButtons.size()==0) {
    for (Button a : Buttons) {
      if (a instanceof PolygonButton2) {
        ActiveButtons.add(a);
      }
    }
  }   
  int index1=(int)(random(0, ActiveButtons.size()));
  int index2=Buttons.indexOf(ActiveButtons.get(index1));
  int a=3;
  switch(index2) {
  case 5: 
    a=3; 
    break;
  case 6: 
    a=4; 
    break;
  case 7: 
    a=5; 
    break;
  case 8: 
    a=6; 
    break;
  case 9: 
    a=7; 
    break;
  case 10: 
    a=8; 
    break;
  case 11: 
    a=9; 
    break;
  case 12: 
    a=10; 
    break;
  case 13: 
    a=12; 
    break;
  case 14: 
    a=15; 
    break;
  case 15: 
    a=20; 
    break;
  case 16: 
    a=50; 
    break;
  }
  return a;
}

boolean lockedL=false;
PVector lockedmouseL;
color lockedSegmentColor;
Segment lockedS;
void createLine() {
  if (mousePressed && (mouseX>=xmin && mouseX<=xmax && mouseY>=ymin && mouseY<=ymax) && !lockedL && mouseButton==RIGHT && !keyPressed) {
    lockedL=true;
    lockedmouseL=new PVector(mouseX, mouseY);
    lockedSegmentColor=getColor();
  }
  if (mousePressed && (mouseX>=xmin && mouseX<=xmax && mouseY>=ymin && mouseY<=ymax) && lockedL && mouseButton==RIGHT && !keyPressed) {
    PVector X=new PVector(mouseX, mouseY);
    lockedS=new Segment(lockedmouseL, X, lockedSegmentColor);
    lockedS.display();
  } else if (lockedL) {
    if (mouseButton!=LEFT) {
      Segments.add(lockedS);
    }
    lockedL=false;
  }
}

void smudgeScreen() {
  ActiveZone.loadPixels();
  for (int x=1; x<Width-1; x++) {
    for (int y=1; y<Height-1; y++) {
      PVector Color[]=new PVector[8];
      Color[0]=new PVector(red(ActiveZone.pixels[(y-1)*Width+(x-1)]), green(ActiveZone.pixels[(y-1)*Width+(x-1)]), blue(ActiveZone.pixels[(y-1)*Width+(x-1)]));
      Color[1]=new PVector(red(ActiveZone.pixels[(y-1)*Width+x]), green(ActiveZone.pixels[(y-1)*Width+x]), blue(ActiveZone.pixels[(y-1)*Width+x]));
      Color[2]=new PVector(red(ActiveZone.pixels[(y-1)*Width+(x+1)]), green(ActiveZone.pixels[(y-1)*Width+(x+1)]), blue(ActiveZone.pixels[(y-1)*Width+(x+1)]));
      Color[3]=new PVector(red(ActiveZone.pixels[y*Width+(x-1)]), green(ActiveZone.pixels[y*Width+(x-1)]), blue(ActiveZone.pixels[y*Width+(x-1)]));
      Color[4]=new PVector(red(ActiveZone.pixels[y*Width+(x+1)]), green(ActiveZone.pixels[y*Width+(x+1)]), blue(ActiveZone.pixels[y*Width+(x+1)]));
      Color[5]=new PVector(red(ActiveZone.pixels[(y+1)*Width+(x-1)]), green(ActiveZone.pixels[(y+1)*Width+(x-1)]), blue(ActiveZone.pixels[(y+1)*Width+(x-1)]));
      Color[6]=new PVector(red(ActiveZone.pixels[(y+1)*Width+x]), green(ActiveZone.pixels[(y+1)*Width+x]), blue(ActiveZone.pixels[(y+1)*Width+x]));
      Color[7]=new PVector(red(ActiveZone.pixels[(y+1)*Width+(x+1)]), green(ActiveZone.pixels[(y+1)*Width+(x+1)]), blue(ActiveZone.pixels[(y+1)*Width+(x+1)]));

      PVector C=new PVector(0, 0, 0);
      for (int i=0; i<8; i++) {
        C.add(Color[i]);
      }
      C.div(8);
      color c=color(C.x, C.y, C.z);
      ActiveZone.set(x, y, c);
    }
  }
}

void showMouseOverText() {
  String text=null;
  for (Button a : Buttons) {
    if (a.IsMouseOver()) {
      text=a.title;
      break;
    }
  }
  if (text==null) {
    for (Bar a : Bars) {
      if (a.IsMouseOver()) {
        text=a.title;
        break;
      }
    }
  }
  if (text==null) {
    for (Button a : ColorChoices.Buttons) {
      if (a.IsMouseOver()) {
        text=a.title;
      }
    }
  }
  if (text==null && mouseX>xmax && mouseX<screenWidth && mouseY<BorderLength) {
    text="Color Picker";
  }
  if (text==null && Buttons.get(1).active && mouseX<BorderLength && mouseY>.25*BorderLength && mouseY<1.25*BorderLength) {
    text="Size & Orientation Picker";
  }
  if (text!=null) {
    int RectangleHeight=(int)(textAscent()-textDescent());
    int RectangleWidth=(int)(textWidth(text))+1;
    PGraphics MouseOverText=createGraphics(RectangleWidth, (int)(1.5*RectangleHeight)+1);
    MouseOverText.beginDraw();
    MouseOverText.stroke(0);
    MouseOverText.fill(255);
    MouseOverText.rect(0, 0, RectangleWidth-1, (int)(1.5*RectangleHeight));
    MouseOverText.fill(0);
    MouseOverText.stroke(0);
    MouseOverText.text(text, 0, 1.25*RectangleHeight);    
    MouseOverText.endDraw();
    if (mouseX+RectangleWidth>Width) {
      image(MouseOverText, mouseX-RectangleWidth, mouseY-(int)(1.5*RectangleHeight)+1);
    } else {
      image(MouseOverText, mouseX, mouseY-(int)(1.5*RectangleHeight)+1);
    }
  }
}
