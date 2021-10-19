ArrayList<Bar>Bars=new ArrayList<Bar>();

class Bar {
  PVector X;
  PVector Breadth;
  float min, max;
  float measure;
  color foreground;
  color background;
  String title;

  Bar(float x, float y, float w, float h, float minimum, float maximum, color forward, color backward, String title) {
    X=new PVector(x, y);
    Breadth=new PVector(w, h);
    min=minimum;
    max=maximum;
    this.title=title;
    measure=.5*(max+min);
    foreground=forward;
    background=backward;
  }

  void display() {
    stroke(background);
    fill(background);
    rect(X.x, X.y, Breadth.x, Breadth.y);  

    fill(foreground);
    float y=X.y+Breadth.y-Breadth.y*(measure-min)/(max-min);
    rect(X.x, y, Breadth.x, Breadth.y*(measure-min)/(max-min));
  }
  void updateMeasure() {
    if (mousePressed && IsMouseOver()) {
      measure=(max-min)*((X.y+Breadth.y-mouseY)/Breadth.y)+min;
    }
  }
  boolean IsMouseOver() {
    return (mouseX>=X.x && mouseX<=X.x+Breadth.x && mouseY>=X.y && mouseY<=X.y+Breadth.y);
  }
}

class FloorBar extends Bar{
  FloorBar(float x, float y, float w, float h, float minimum, float maximum, color forward, color backward, String title){
    super(x,y,w,h,minimum,maximum,forward,backward,title);
  }
  void updateMeasure(){
    if (mousePressed && IsMouseOver()) {
      measure=(float)Math.floor(5*((max-min)*((X.y+Breadth.y-mouseY)/Breadth.y)+min))/5;
    }
  }
}

class HorizontalBar extends Bar {
  HorizontalBar(float x, float y, float w, float h, float min, float max, color forward, color backward, String title) {
    super(x, y, w, h, min, max, forward, backward, title);
  }  

  void display() {
    stroke(background);
    fill(background);
    rect(X.x, X.y, Breadth.x, Breadth.y);  

    fill(foreground);
    rect(X.x, X.y, Breadth.x*(measure-min)/(max-min), Breadth.y);
  }  

  void updateMeasure() {
    if (mousePressed && IsMouseOver()) {
      measure=(max-min)*(mouseX-X.x)/Breadth.x+min;
    }
  }
}

class SplitVerticalBar extends Bar { //assumes min
  color complement;
  SplitVerticalBar(float x, float y, float w, float h, float GreatestMagnitude, color forward, color backward, String title) {
    super(x, y, w, h, -GreatestMagnitude, GreatestMagnitude, forward, backward, title);
    float R = red(forward);
    float G = green(forward);
    float B = blue(forward);
    float minRGB = min(R, min(G, B));
    float maxRGB = max(R, max(G, B));
    float minPlusMax = minRGB + maxRGB;
    complement = color(minPlusMax-R, minPlusMax-G, minPlusMax-B);
  }

  void display() {
    stroke(background);
    fill(background);
    rect(X.x, X.y, Breadth.x, Breadth.y);
    fill(foreground);   
    int sign = (int) Math.signum(measure);
    switch(sign) {
    case -1:
    fill(complement);
      rect(X.x, X.y+.5*Breadth.y, Breadth.x, .5*Breadth.y*measure/min);
      break;
    case 1:
      rect(X.x, X.y+.5*Breadth.y-(measure/max)*.5*Breadth.y, Breadth.x, (measure/max)*.5*Breadth.y);
      break;
    }
  }
}

class SplitHorizontalBar extends HorizontalBar{
  color complement;
  SplitHorizontalBar(float x, float y, float w, float h, float GreatestMagnitude, color forward, color backward, String title) {
    super(x, y, w, h, -GreatestMagnitude, GreatestMagnitude, forward, backward, title);
    float R = red(forward);
    float G = green(forward);
    float B = blue(forward);
    float minRGB = min(R, min(G, B));
    float maxRGB = max(R, max(G, B));
    float minPlusMax = minRGB + maxRGB;
    complement = color(minPlusMax-R, minPlusMax-G, minPlusMax-B);
  }
  void display() {
    stroke(background);
    fill(background);
    rect(X.x, X.y, Breadth.x, Breadth.y);
    fill(foreground);
    int sign = (int) Math.signum(measure);
    switch(sign) {
    case -1:
      fill(complement);
      rect(X.x+.5*Breadth.x-(measure/min)*.5*Breadth.x, X.y, (measure/min)*.5*Breadth.x, Breadth.y);     
      break;
    case 1:
      rect(X.x+.5*Breadth.x, X.y, (measure/max)*.5*Breadth.x, Breadth.y);
      break;
    }
  }
}
