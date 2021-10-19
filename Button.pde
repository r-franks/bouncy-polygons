ArrayList<Button>Buttons=new ArrayList<Button>();
class Button {
  PVector X;
  PVector Breadth;
  color Color;
  String title;
  boolean active;
  Button(float x, float y, float w, float h, color Color, String title) {
    X=new PVector(x, y);
    Breadth=new PVector(w, h);
    this.Color=Color;
    this.title=title;
    active=false;
  }
  void display() {
    stroke(Color);
    fill(Color);
    rect(X.x, X.y, Breadth.x, Breadth.y);
    if (active) {
      stroke(0, 0, 0, 125);
      fill(0, 0, 0, 125);
      rect(X.x, X.y, Breadth.x, Breadth.y);
    }
  }
  void updateStatus() { //to be used in mouseClicked()
    if (IsMouseOver()) {
      active=!active;
    }
  }
  boolean IsMouseOver() {
    return (mouseX>=X.x && mouseX<=X.x+Breadth.x && mouseY>=X.y && mouseY<=X.y+Breadth.y);
  }
}
class PolygonButton1 extends Button {
  PShape Polygon;
  color PColor;
  color sColor;
  PolygonButton1(float x, float y, float w, float h, color sColor, color PColor, color BColor, int Sides, String title) {
    super(x, y, w, h, BColor, title);
    Polygon=createShape();
    Polygon.beginShape();
    Polygon.stroke(sColor);
    Polygon.fill(PColor);
    Polygon.beginContour();
    float angle=2*PI/Sides;
    float Circumradius=.4*min(w, h);
    for (int i=0; i<=Sides; i++) {
      PVector vertex=new PVector(Circumradius*cos(angle*i-PI/2), Circumradius*sin(angle*i-PI/2));
      Polygon.vertex(vertex.x, vertex.y);
    }
    Polygon.endContour();
    Polygon.endShape();
  }
  void display() {    
    stroke(Color);
    fill(Color);
    rect(X.x, X.y, Breadth.x, Breadth.y);
    shape(Polygon, X.x+Breadth.x*.5, X.y+Breadth.y*.5);
    if (active) {
      stroke(0, 0, 0, 125);
      fill(0, 0, 0, 125);
      rect(X.x, X.y, Breadth.x, Breadth.y);
    }
  }
}
class PolygonButton2 extends PolygonButton1 {
  PolygonButton2(float x, float y, float w, float h, color Color, int Sides, String title) {
    super(x, y, w, h, color(min(red(Color), min(green(Color), blue(Color))) + max(red(Color), max(green(Color), blue(Color)))-red(Color), min(red(Color), min(green(Color), blue(Color))) + max(red(Color), max(green(Color), blue(Color)))-red(Color), min(red(Color), min(green(Color), blue(Color))) + max(red(Color), max(green(Color), blue(Color)))-blue(Color)), color(min(red(Color), min(green(Color), blue(Color))) + max(red(Color), max(green(Color), blue(Color)))-red(Color), min(red(Color), min(green(Color), blue(Color))) + max(red(Color), max(green(Color), blue(Color)))-red(Color), min(red(Color), min(green(Color), blue(Color))) + max(red(Color), max(green(Color), blue(Color)))-blue(Color)), Color, Sides, title);
  }
  void display() {    
    stroke(Color);
    fill(Color);
    rect(X.x, X.y, Breadth.x, Breadth.y);
    shape(Polygon, X.x+Breadth.x*.5, X.y+Breadth.y*.5);
    if (active) {
      stroke(0, 0, 0, 125);
      fill(0, 0, 0, 125);
      rect(X.x, X.y, Breadth.x, Breadth.y);
    }
  }
}
ButtonToggler ColorChoices;
class ButtonToggler {
  ArrayList<Button>Buttons;
  Button ActiveButton;
  ButtonToggler(ArrayList<Button>Buttons) {
    this.Buttons=Buttons;
    Buttons.get(0).active=true;
    ActiveButton=Buttons.get(0);
  } 
  void updateStatus() {
    ArrayList<Button>UnactiveButtons=new ArrayList<Button>();
    UnactiveButtons.addAll(Buttons);
    UnactiveButtons.remove(ActiveButton);
    for (Button a : UnactiveButtons) {
      if (a.IsMouseOver()) {
        for (Button b : Buttons) {
          b.active=false;
        }
        a.active=true;
        ActiveButton=a;
      }
    }
  }
  void display() {
    for (Button a : Buttons) {
      a.display();
    }
  }
  int getIndexOfActiveButton(){
    return Buttons.indexOf(ActiveButton);
  }
}
