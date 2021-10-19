ArrayList<Segment>Segments=new ArrayList<Segment>();

class Segment{
  PVector v1;
  PVector v2;
  PVector N;
  color Color;
  float Tone;
  
  Segment(PVector v1, PVector v2, color Color){
    this.v1=v1;
    this.v2=v2;
    this.Color=Color;
    PVector T=PVector.sub(v2,v1);
    N=new PVector(-T.y,T.x);
    N.normalize();
    Tone=getTone(red(Color),green(Color),blue(Color));
  }
  
  void display(){
    ActiveZone.stroke(Color);
    ActiveZone.fill(Color);
    ActiveZone.line(v1.x-xmin, v1.y-ymin, v2.x-xmin, v2.y-ymin);
  }
  
  boolean equals(Segment S){
    if(S==null){
      return false;
    }else if(v1.x==S.v1.x && v1.y==S.v1.y && v2.x==S.v2.x && v2.y==S.v2.y && red(Color)==red(S.Color) && blue(Color)==blue(S.Color) && green(Color)==green(S.Color)){
      return true;
    }else{
      return false;
    }
  }
}
