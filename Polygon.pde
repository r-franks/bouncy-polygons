ArrayList<Polygon>Polygons=new ArrayList<Polygon>();
class Polygon {
  PShape Shape;
  color Color;

  PVector X;
  PVector prevX;
  float theta;
  PVector V;
  PVector prevV;
  PVector W;

  float Mass;
  float InverseMass;
  float MoI;
  float InverseMoI;
  float Circumradius;
  float Innerradius;
  int SideNumber;

  int ID;

  float Tone, Loudness, Duration;
  Polygon PrevCollidedPolygon=null;
  Segment PrevCollidedSegment=null;  
  int PrevCollidedSide=0;
  ArrayList<PVector>Normals;

  public Polygon(float x, float y, float theta, PVector V, float dthetadt, float Circumradius, int SideNumber, color Color, int ID) {
    this.ID=ID;
    X=new PVector(x, y);
    this.theta=theta;
    this.V=V;
    W=PVector.mult(new PVector(0, 0, 1), -dthetadt);
    this.Circumradius=Circumradius;
    this.SideNumber=SideNumber;
    this.Color=Color;
    prevX=X;
    prevV=V;

    Innerradius=2*Circumradius*sin(PI/SideNumber);

    Mass=.5*SideNumber*sin(2*PI/SideNumber)*Circumradius*Circumradius;
    InverseMass=1/Mass;

    float sidelength=2*Circumradius*sin(PI/SideNumber);
    float cot=1/tan(PI/SideNumber);
    MoI=(Mass*sidelength*sidelength/24)*(1+3/(cot*cot));
    InverseMoI=1/MoI;

    Tone=getTone(red(Color), green(Color), blue(Color));
    float NormalizedMass=Mass/Area;
    Duration=ceil(100*NormalizedMass);
    Loudness=ceil(20+80*NormalizedMass);

    Shape=createShape();
    Shape.beginShape();
    Shape.stroke(Color);
    Shape.fill(Color);
    Shape.beginContour();
    float angle=2*PI/SideNumber;
    for (int i=0; i<=SideNumber; i++) {
      PVector vertex=new PVector(Circumradius*cos(angle*i-PI/2+theta), Circumradius*sin(angle*i-PI/2+theta));
      Shape.vertex(vertex.x, vertex.y);
    }
    Shape.endContour();
    Shape.endShape();
    Shape.disableStyle();

    Normals=getNormalVectors();
  }

  void move() {
    prevX=X;
    prevV=V;
    X=PVector.add(X, PVector.mult(V, Bars.get(5).measure));
    Shape.rotate(W.dot(new PVector(0, 0, 1))*Bars.get(5).measure);
  }
  void collide(Polygon P) {
    float InverseTotMass=1/(P.Mass+Mass);
    PVector PtoThisPolygon=PVector.sub(X, P.X);
    if (PtoThisPolygon.magSq()<(Circumradius+P.Circumradius)*(Circumradius+P.Circumradius)) {
      ArrayList<PVector>Axes=new ArrayList<PVector>();
      Axes.addAll(Normals);
      Axes.addAll(P.Normals);

      boolean collision=true;
      PVector SmallestAxis=null;
      float MinimumOverlap=100000000;
      for (PVector a : Axes) {
        PVector proj1=getProjection(a);
        PVector proj2=P.getProjection(a);
        float Overlap=min(proj1.y, proj2.y)-max(proj1.x, proj2.x);
        if (Overlap>0) {
          if (Overlap<MinimumOverlap) {
            MinimumOverlap=Overlap;
            SmallestAxis=a;
          }
        } else {
          collision=false;
          break;
        }
      }
      if (collision) {
        PrevCollidedPolygon=P;
        PVector N=SmallestAxis;       
        ArrayList<PVector> ContactPoints=getPolygonCollisionPoints(P);
        int Contacts=ContactPoints.size();
        float c=sqrt(Bars.get(2).measure);
        if (Contacts>0) {
          if (PVector.sub(X, P.X).dot(PVector.sub(V, P.V))<0) {
            float impulse=0;
            PVector H=new PVector(-N.y, N.x);  
            PVector ContactPoint=new PVector(0, 0);      
            for (PVector v : ContactPoints) {
              ContactPoint.add(v);
              PVector r1=PVector.sub(v, X);
              PVector r2=PVector.sub(v, P.X);
              PVector V1=PVector.add(V, W.cross(r1));
              PVector V2=PVector.add(P.V, P.W.cross(r2));
              PVector relV=PVector.sub(V1, V2);
              float j=-((1+c)*relV.dot(N))/(InverseMass+P.InverseMass+r1.cross(N).magSq()*InverseMoI+r2.cross(N).magSq()*P.InverseMoI);
              impulse=j;
              applyImpulse(-j, N, r1);
              P.applyImpulse(j, N, r2);
            }   
            ContactPoint.div(Contacts);
            PVector rThis=PVector.sub(ContactPoint, X);
            PVector rP=PVector.sub(ContactPoint, P.X);        
            PVector VThis=PVector.add(V, W.cross(rThis));
            PVector VP=PVector.add(P.V, P.W.cross(rP));
            PVector Vrel=PVector.sub(VP, VThis);
            applyFriction(impulse, H, rThis, PVector.mult(Vrel, -1));
            P.applyFriction(impulse, H, rP, Vrel);
          }
          PVector MoveThis=PVector.mult(N, Mass*InverseTotMass*MinimumOverlap);
          PVector MoveP=PVector.mult(N, -P.Mass*InverseTotMass*MinimumOverlap);          
          if (MoveP.dot(PtoThisPolygon)>0) {
            MoveThis.mult(-1);
            MoveP.mult(-1);
          }          
          X.add(MoveThis);
          P.X.add(MoveP);
        } else {
          PVector CenterVector=PVector.sub(X, P.X);
          float dist=CenterVector.mag();
          if (dist==0) {
            CenterVector=PVector.random2D();
          }
          CenterVector.setMag(P.Circumradius+Circumradius-dist);
          X.sub(PVector.mult(CenterVector, Mass*InverseTotMass));
          P.X.add(PVector.mult(CenterVector, P.Mass*InverseTotMass));
        }
      }
    }
  }

  void collide(Segment S) {
    PVector SegmentIntersection=SegmentIntersection(S.v1, S.v2, prevX, X);
    if (SegmentIntersection!=null) {
      X=prevX;
      PVector CenterToIntersect=PVector.sub(SegmentIntersection, X);
      CenterToIntersect.normalize();
      PVector N=S.N;
      float c=Bars.get(2).measure;
      PVector r;
      PVector Contact=SegmentIntersection(S.v1, S.v2, X, PVector.add(pointToSegment(S.v1, S.v2, X), X));
      if (Contact!=null) {
        r=PVector.sub(Contact, X);
      } else {
        r=new PVector(0, 0);
      }    
      PVector Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      float impulse=-(1+c)*Vrel.dot(N)/(InverseMass+r.cross(N).magSq()*InverseMoI);
      applyImpulse(impulse, N, r);
      Vrel=PVector.add(V, W.cross(r));     
      applyFriction(impulse, new PVector(-N.y, N.x), r, Vrel);
      Shape.rotate(-W.dot(new PVector(0, 0, 1))*Bars.get(5).measure);

      PVector H=new PVector(-N.y, N.x);
      PVector newX=PVector.add(X, PVector.mult(H, V.dot(H)*Bars.get(5).measure));
      if (SegmentIntersection(S.v1, S.v2, X, newX)==null) {
        PVector I=null;
        PVector D=new PVector(100000, 100000);
        float DmagSq=D.magSq();
        for (Segment a : Segments) {
          PVector newI=SegmentIntersection(a.v1, a.v2, X, newX);
          if (I!=null) {
            PVector newD=PVector.sub(I, X);
            float newDmagSq=newD.magSq();
            if (newDmagSq<DmagSq) {
              I=newI;
              D=newD;
              DmagSq=newDmagSq;
            }
          }
        }
        if (I!=null) {
          if (D.mag()>Circumradius) {
            D.setMag(D.mag()-Circumradius);
          } else {
            D.mult(0.5);
          }
          X.add(D);
        } else {
          X=newX;
        }
      }
    } else {
      PVector closestPoint=closestPointOnLineSegment(S.v1, S.v2, X);
      PVector line2center=PVector.sub(closestPoint, X);
      if (PVector.sub(X, closestPoint).magSq()<Circumradius*Circumradius && V.dot(line2center)>=0) {
        ArrayList<PVector>Intersections=getIntersections(S.v1, S.v2);
        if (Intersections.size()!=0) {
          float c=Bars.get(2).measure;

          PVector MostOverlap=PVector.add(Shape.getVertex(0), X);
          PVector Scoot=PVector.sub(closestPointOnLineSegment(S.v1, S.v2, MostOverlap), MostOverlap);
          for (int i=1; i<SideNumber; i++) {
            PVector v=PVector.add(Shape.getVertex(i), X);
            PVector vline=closestPointOnLineSegment(S.v1, S.v2, v);
            PVector NewScoot=PVector.sub(vline, v);
            if (NewScoot.dot(line2center)<Scoot.dot(line2center)) {
              Scoot=NewScoot;
            }
          }
          if (abs(line2center.dot(S.N))==line2center.mag()) {
            c=sqrt(c);
            float impulse=0;
            PVector r=new PVector(0, 0);
            for (PVector Intersection : Intersections) {
              r=PVector.sub(Intersection, X);
              PVector Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
              impulse=-(1+c)*Vrel.dot(S.N)/(InverseMass+r.cross(S.N).magSq()*InverseMoI);
              applyImpulse(impulse, S.N, r);
            }
            PVector Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
            applyFriction(impulse, new PVector(-S.N.y, S.N.x), r, Vrel);
          } else {
            PVector r=PVector.mult(line2center, -1);
            PVector Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
            PVector N;
            N=line2center;
            N.normalize();
            float impulse=-(1+c)*Vrel.dot(N)/(InverseMass+r.cross(N).magSq()*InverseMoI);
            applyImpulse(impulse, N, r);    

            Vrel=PVector.add(V, W.cross(r));
            applyFriction(impulse, new PVector(-N.y, N.x), r, Vrel);
          }
          PVector newX=PVector.add(Scoot, X);
          PVector I=null;
          PVector D=new PVector(100000, 100000);
          float DmagSq=D.magSq();
          for (Segment a : Segments) {
            PVector newI=SegmentIntersection(a.v1, a.v2, X, newX);
            if (I!=null) {
              PVector newD=PVector.sub(I, X);
              float newDmagSq=newD.magSq();
              if (newDmagSq<DmagSq) {
                I=newI;
                D=newD;
                DmagSq=newDmagSq;
              }
            }
          }
          if (I!=null) {
            if (D.mag()>Circumradius) {
              D.setMag(D.mag()-Circumradius);
            } else {
              D.mult(0.5);
            }
            X.add(D);
          } else {
            X=newX;
          }
        } else {
          PrevCollidedSegment=null;
        }
      }
    }
  } 
  void checkWalls() {
    PVector PminX=PVector.add(Shape.getVertex(0), X);
    PVector PmaxX=PVector.add(Shape.getVertex(0), X);
    PVector PminY=PVector.add(Shape.getVertex(0), X);
    PVector PmaxY=PVector.add(Shape.getVertex(0), X);
    for (int i=1; i<SideNumber; i++) {
      PVector v1=PVector.add(Shape.getVertex(i), X);
      if (v1.x<PminX.x) {
        PminX=v1;
      } else if (v1.x>PmaxX.x) {
        PmaxX=v1;
      }
      if (v1.y<PminY.y) {
        PminY=v1;
      } else if (v1.y>PmaxY.y) {
        PmaxY=v1;
      }
    }
    boolean XminCollision=false;
    boolean XmaxCollision=false;
    boolean YminCollision=false;
    boolean YmaxCollision=false;

    float c=Bars.get(2).measure;

    PVector Scoot=new PVector(0, 0, 0);
    boolean NoIntersection=false;
    ArrayList<PVector>minXCollisions=new ArrayList<PVector>();
    ArrayList<PVector>maxXCollisions=new ArrayList<PVector>();
    ArrayList<PVector>minYCollisions=new ArrayList<PVector>();
    ArrayList<PVector>maxYCollisions=new ArrayList<PVector>();
    float ContactSpots=0;

    int CollidedSide=0;
    if (PminX.x<=xmin) {
      CollidedSide=1;
      ContactSpots+=1;
      Scoot.x-=(PminX.x-xmin);
      minXCollisions.addAll(getIntersections(new PVector(xmin, ymin), new PVector(xmin, ymax)));
      if (minXCollisions.size()==0) {
        minXCollisions.add(PminX);
        NoIntersection=true;
      }
    }      
    if (PmaxX.x>=xmax) {
      CollidedSide=2;      
      ContactSpots+=1;      
      Scoot.x-=(PmaxX.x-xmax);
      maxXCollisions.addAll(getIntersections(new PVector(xmax, ymin), new PVector(xmax, ymax)));
      if (maxXCollisions.size()==0) {
        maxXCollisions.add(PmaxX);
        NoIntersection=true;
      }
    }
    if (PminY.y<=ymin) {
      CollidedSide=3;
      ContactSpots+=1;      
      Scoot.y-=(PminY.y-ymin);
      minYCollisions.addAll(getIntersections(new PVector(xmin, ymin), new PVector(xmax, ymin)));
      if (minYCollisions.size()==0) {
        minYCollisions.add(PminY);
        NoIntersection=true;
      }
    }
    if (PmaxY.y>=ymax) {
      CollidedSide=4;
      ContactSpots+=1;      
      Scoot.y-=(PmaxY.y-ymax);
      maxYCollisions.addAll(getIntersections(new PVector(xmin, ymax), new PVector(xmax, ymax)));
      if (maxYCollisions.size()==0) {
        maxYCollisions.add(PmaxY);
        NoIntersection=true;
      }
    }
    if (ContactSpots>1) {
      c=sqrt(c);
    }
    boolean Collision=false;
    if (V.x<0 && minXCollisions.size()>0) {
      Collision=true;
      PVector N=new PVector(1, 0);
      PVector CollisionPoint=new PVector(0, 0, 0);
      for (PVector a : minXCollisions) {
        CollisionPoint.add(a);
      }
      CollisionPoint.div(minXCollisions.size());
      PVector r=PVector.sub(CollisionPoint, X);
      if (NoIntersection) {
        r=PVector.sub(new PVector(PminX.x, X.y), X);
      }
      PVector Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      float impulse=-(1+c)*Vrel.dot(N)/(InverseMass+r.cross(N).magSq()*InverseMoI);
      applyImpulse(impulse, N, r);
      Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      applyFriction(impulse, new PVector(-N.y, N.x), r, Vrel);
    }
    if (V.x>0 && maxXCollisions.size()>0) {
      Collision=true;
      PVector N=new PVector(-1, 0);
      PVector CollisionPoint=new PVector(0, 0);
      for (PVector a : maxXCollisions) {
        CollisionPoint.add(a);
      }
      CollisionPoint.div(maxXCollisions.size());
      PVector r=PVector.sub(CollisionPoint, X);
      if (NoIntersection) {
        r=PVector.sub(new PVector(PmaxX.x, X.y), X);
      }
      PVector Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      float impulse=-(1+c)*Vrel.dot(N)/(InverseMass+r.cross(N).magSq()*InverseMoI);
      applyImpulse(impulse, N, r);

      Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      applyFriction(impulse, new PVector(-N.y, N.x), r, Vrel);
    }
    if (V.y<0 && minYCollisions.size()>0) {
      Collision=true;
      PVector N=new PVector(0, 1);
      PVector CollisionPoint=new PVector(0, 0);
      for (PVector a : minYCollisions) {
        CollisionPoint.add(a);
      }
      CollisionPoint.div(minYCollisions.size());
      PVector r=PVector.sub(CollisionPoint, X);
      if (NoIntersection) {
        r=PVector.sub(new PVector(X.x, PminY.y), X);
      }
      PVector Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      float impulse=-(1+c)*Vrel.dot(N)/(InverseMass+r.cross(N).magSq()*InverseMoI);
      applyImpulse(impulse, N, r);

      Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      applyFriction(impulse, new PVector(-N.y, N.x), r, Vrel);
    }
    if (V.y>0 && maxYCollisions.size()>0) {
      Collision=true;
      PVector N=new PVector(0, -1);
      PVector CollisionPoint=new PVector(0, 0);
      for (PVector a : maxYCollisions) {
        CollisionPoint.add(a);
      }
      CollisionPoint.div(maxYCollisions.size());
      PVector r=PVector.sub(CollisionPoint, X);
      if (NoIntersection) {
        r=PVector.sub(new PVector(X.x, PmaxY.y), X);
      }
      PVector Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      float impulse=-(1+c)*Vrel.dot(N)/(InverseMass+r.cross(N).magSq()*InverseMoI);
      applyImpulse(impulse, N, r);

      Vrel=PVector.sub(new PVector(0, 0), PVector.add(V, W.cross(r)));
      applyFriction(impulse, new PVector(-N.y, N.x), r, Vrel);
    }
    PrevCollidedSide=CollidedSide;
    X.add(Scoot);
  }

  void applyImpulse(float impulse, PVector N, PVector CenterToContact) {  
    PVector Impulse=PVector.mult(N, impulse);
    V.sub(PVector.mult(Impulse, InverseMass));
    W.sub(PVector.mult(CenterToContact.cross(Impulse), InverseMoI));
  }

  void applyFriction(float impulse, PVector H, PVector CenterToContact, PVector Vrel) {
    float E=0.5*Mass*V.magSq()+0.5*MoI*W.magSq();
    impulse=abs(impulse);
    if (H.dot(V)<0) {
      H.mult(-1);
    }
    float J;
    float Jmax;
    if (Vrel.dot(H)>=0) {
      Jmax=min(Mass*Vrel.dot(H), Mass*V.dot(H));
    } else {
      Jmax=Mass*V.dot(H);
    }
    if (Bars.get(3).measure*impulse>Jmax) {
      J=Jmax;
    } else {
      J=Bars.get(3).measure*impulse;
    }
    PVector newV=PVector.sub(V, PVector.mult(H, J*InverseMass));
    PVector newW=PVector.sub(W, PVector.mult(CenterToContact.cross(H), InverseMoI*J));
    if (0.5*Mass*newV.magSq()+0.5*MoI*newW.magSq()<=E) {
      V=newV;
      W=newW;
    } else {
      V=newV;
    }
  }

  void applyGravity(Polygon p) {
    PVector Distance=PVector.sub(X, p.X);
    if (Distance.magSq()>(p.Innerradius+Innerradius)*(p.Innerradius+Innerradius)) {
      float T=Bars.get(5).measure;
      float G=Bars.get(4).measure;
      float GravityImpulse=T*G*p.Mass*Mass/Distance.magSq();
      float ThisAcceleration=-GravityImpulse*InverseMass;
      float PAcceleration=GravityImpulse*p.InverseMass;
      V.add(PVector.mult(Distance, ThisAcceleration));
      p.V.add(PVector.mult(Distance, PAcceleration));
    }
  }
  void display() {
    switch(ColorChoices.getIndexOfActiveButton()) {
    case 0:
      ActiveZone.fill(Color);
      ActiveZone.stroke(Color);
      ActiveZone.shape(Shape, X.x-xmin, X.y-ymin);
      break;
    case 1:
      ActiveZone.fill(255, 255, 255, alpha(Color));
      ActiveZone.stroke(Color);
      ActiveZone.shape(Shape, X.x-xmin, X.y-ymin);
      break;
    case 2:
      ActiveZone.noFill();
      ActiveZone.stroke(Color);
      ActiveZone.shape(Shape, X.x-xmin, X.y-ymin);
      break;
    case 3:
      break;
    }
    Color=color(red(Color), green(Color), blue(Color), alpha(Color)-(255-Bars.get(8).measure));
    if (Bars.get(6).measure*Bars.get(5).measure!=0) {
      PVector displayV=PVector.mult(V, Bars.get(6).measure*Bars.get(5).measure);
      ActiveZone.stroke(0);
      ActiveZone.line(X.x-xmin, X.y-ymin, X.x+displayV.x-xmin, X.y+displayV.y-ymin);
    }
  }
  ArrayList<PVector> getPolygonCollisionPoints(Polygon P) {
    PVector ContactPoint=new PVector(0, 0);
    ArrayList<PVector>Intersections=new ArrayList<PVector>();
    for (int i=0; i<SideNumber; i++) {
      PVector v1=PVector.add(Shape.getVertex(i), X);
      PVector v2;
      if (i==SideNumber-1) {
        v2=PVector.add(Shape.getVertex(0), X);
      } else {
        v2=PVector.add(Shape.getVertex(i+1), X);
      }
      ArrayList<PVector> edgeIntersections=P.getIntersections(v1, v2);
      if (edgeIntersections.size()>0) {
        for (PVector intersection : edgeIntersections) {
          if (intersection!=null) {
            Intersections.add(intersection);
          }
        }
      }
    }
    return Intersections;
  }
  ArrayList<PVector> getNormalVectors() {
    ArrayList<PVector>Axes=new ArrayList<PVector>();
    int Sides;
    if (SideNumber%2==0) {
      Sides=SideNumber/2;
    } else {
      Sides=SideNumber;
    }
    for (int i=0; i<Sides; i++) {
      PVector v1=Shape.getVertex(i);
      PVector v2;
      if (i==Sides-1) {
        v2=Shape.getVertex(0);
      } else {
        v2=Shape.getVertex(i+1);
      }
      PVector axis=PVector.sub(v2, v1);
      axis.normalize();
      axis=new PVector(-axis.y, axis.x);
      Axes.add(axis);
    }
    return Axes;
  }           
  PVector getProjection(PVector Axis) { //x is min, y is max
    float min=Axis.dot(PVector.add(Shape.getVertex(0), X));
    float max=min;
    for (int i=0; i<SideNumber; i++) {
      float proj=Axis.dot(PVector.add(Shape.getVertex(i), X));
      if (proj>max) {
        max=proj;
      } else if (proj<min) {
        min=proj;
      }
    }
    return new PVector(min, max);
  }

  ArrayList<PVector> getIntersectionsWithSegment(Segment S) {
    return getIntersections(S.v1, S.v2);
  }

  boolean pointInPolygon(PVector point) {
    boolean inPolygon=true;
    float dsquared=PVector.sub(point, X).magSq();
    if (dsquared<Circumradius*Circumradius) {
      return true;
    } else if (dsquared>radius*radius) {
      return false;
    } else {
      PVector rayV1=point;
      PVector rayV2=new PVector(100000, point.y);
      int intersections=0;
      for (int i=0; i<SideNumber; i++) {
        PVector v1=PVector.add(Shape.getVertex(i), X);
        PVector v2;
        //gets vertex if the previous vertex was the last new one
        if (i==SideNumber-1) {
          v2=PVector.add(Shape.getVertex(0), X);
        } else {
          v2=PVector.add(Shape.getVertex(i+1), X);
        }
        if (SegmentIntersection(rayV1, rayV2, v1, v2)!=null) {
          intersections+=1;
        }
      }
      if (intersections%2==0) {
        return false;
      } else {
        return true;
      }
    }
  }

  ArrayList<PVector> getIntersections(PVector v1, PVector v2) {
    ArrayList<PVector>PointsOfContact=new ArrayList<PVector>(); //calculates intersections between vertices
    for (int q=0; q<SideNumber; q++) {
      PVector v3=PVector.add(Shape.getVertex(q), X);
      PVector v4;
      if (q==SideNumber-1) {
        v4=PVector.add(Shape.getVertex(0), X);
      } else {
        v4=PVector.add(Shape.getVertex(q+1), X);
      }
      PVector PoC=null;
      PoC=SegmentIntersection(v1, v2, v3, v4);
      if (PoC!=null) {
        PointsOfContact.add(PoC);
      }
    }
    return PointsOfContact;
  }

  boolean equals(Polygon P) {
    if (P==null) {
      return false;
    }
    if (ID==P.ID) {
      return true;
    } else {
      return false;
    }
  }
}

PVector closestPointOnLineSegment(PVector v1, PVector v2, PVector p) {
  PVector TestPoint1=PVector.add(pointToSegment(v1, v2, p), p);
  if (TestPoint1.x<=max(v1.x, v2.x) && TestPoint1.x>=min(v1.x, v2.x) && TestPoint1.y<=max(v1.y, v2.y) && TestPoint1.y>=min(v1.y, v2.y) ) {
    return TestPoint1;
  } else {
    if (PVector.sub(p, v1).magSq()>PVector.sub(p, v2).magSq()) {
      return v2;
    } else {
      return v1;
    }
  }
}

PVector pointToSegment(PVector v1, PVector v2, PVector p) {  //gives vector normal to the segment which passes through the point (in direction of the segment)
  PVector pointToSegment=null;
  PVector H=PVector.sub(v2, v1);
  H.normalize();
  PVector N=new PVector(-H.y, H.x);
  if (N.x!=0 && H.x!=0) {
    float m1=N.y/N.x;
    float b1=p.y-m1*p.x;
    float m2=H.y/H.x;
    float b2=v1.y-m2*v1.x;
    float x=(b2-b1)/(m1-m2);
    PVector intersect=new PVector(x, m1*x+b1);
    pointToSegment=PVector.sub(intersect, p);
    pointToSegment=PVector.sub(intersect, p);
  } else if (N.x==0 && H.x!=0) {
    PVector intersect=new PVector(p.x, v1.y-p.y);
    pointToSegment=PVector.sub(intersect, p);
  } else if (H.x==0 && N.x!=0) {
    PVector intersect=new PVector(v1.x-p.x, p.y);
    pointToSegment=PVector.sub(intersect, p);
  } else { //segment was secretly a point the whole time
    pointToSegment=PVector.sub(v1, p);
  }
  return pointToSegment;
}

PVector SegmentIntersection(PVector segment1v1, PVector segment1v2, PVector segment2v1, PVector segment2v2) {
  float segment1max=max(segment1v1.x, segment1v2.x);
  float segment1min=min(segment1v1.x, segment1v2.x); 
  float segment2max=max(segment2v1.x, segment2v2.x);
  float segment2min=min(segment2v1.x, segment2v2.x);
  if (max(segment1min, segment2min)>min(segment1max, segment2max)) {
    return null;
  } else if (segment1v1.x!=segment1v2.x && segment2v1.x!=segment2v2.x) {
    float a1=(segment1v1.y-segment1v2.y)/(segment1v1.x-segment1v2.x);
    float a2=(segment2v1.y-segment2v2.y)/(segment2v1.x-segment2v2.x);
    float b1=segment1v1.y-a1*segment1v1.x;
    float b2=segment2v1.y-a2*segment2v1.x;
    if (a1==a2) { //if parallel they can't intersect
      return null;
    } else { //find point of intersection
      float x=(b2-b1)/(a1-a2);
      if (x<max(segment1min, segment2min) || x>min(segment1max, segment2max)) {
        return null;
      } else {
        return new PVector(x, a1*x+b1);
      }
    }
  } else {
    if (segment1v1.x==segment1v2.x && segment2v1.x!=segment2v2.x && segment1v1.x>segment2min && segment1v1.x<segment2max) {
      float x=segment1v1.x;
      float a=(segment2v1.y-segment2v2.y)/(segment2v1.x-segment2v2.x);
      float b=segment2v1.y-a*segment2v1.x;
      float y=a*x+b;
      if (y>min(segment1v1.y, segment1v2.y) && y<max(segment1v1.y, segment1v2.y)) {
        return new PVector(x, y);
      } else {
        return null;
      }
    } else if (segment2v1.x==segment2v2.x && segment1v1.x!=segment1v2.x && segment2v1.x>segment1min && segment2v1.x<segment1max) {
      float x=segment2v1.x;
      float a=(segment1v1.y-segment1v2.y)/(segment1v1.x-segment1v2.x);
      float b=segment1v1.y-a*segment1v1.x;
      float y=a*x+b;
      if (y>min(segment2v1.y, segment2v2.y) && y<max(segment2v1.y, segment2v2.y)) {
        return new PVector(x, y);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}

int getTone(float r, float g, float  b) { 
  //uses leaat squares to find color (and corresponding tone) nearest to ball's. Tones and associated colors mapped with method outlined here: http://www.endolith.com/wordpress/2010/09/15/a-mapping-between-musical-notes-and-colors/
  //RGB conversion done here: http://academo.org/demos/wavelength-to-colour-relationship/
  float d=(r-97)*(r-97)+(g-0)*(g-0)+(b-0)*(b-0);
  int t=65;

  if ((r-255)*(r-255)+(g-0)*(g-0)+(b-0)*(b-0)<d) {
    d=(r-255)*(r-255)+(g-0)*(g-0)+(b-0)*(b-0);
    t=67;
  } 
  if ((r-255)*(r-255)+(g-119)*(g-119)+(b-0)*(b-0)<d) {
    d=(r-255)*(r-255)+(g-119)*(g-119)+(b-0)*(b-0);
    t=69;
  } 
  if ((r-255)*(r-255)+(g-239)*(g-239)+(b-0)*(b-0)<d) {
    d=(r-255)*(r-255)+(g-239)*(g-239)+(b-0)*(b-0);
    t=70;
  }
  if ((r-58)*(r-58)+(g-255)*(g-255)+(b-0)*(b-0)<d) {
    d=(r-58)*(r-58)+(g-255)*(g-255)+(b-0)*(b-0);
    t=72;
  } 
  if ((r-0)*(r-0)+(g-142)*(g-142)+(b-255)*(b-255)<d) {
    d=(r-0)*(r-0)+(g-142)*(g-142)+(b-255)*(b-255);
    t=74;
  }   
  if ((r-120)*(r-120)+(g-0)*(g-0)+(b-233)*(b-233)<d) {
    d=(r-120)*(r-120)+(g-0)*(g-0)+(b-233)*(b-233);
    t=76;
  }  
  if ((r-121)*(r-121)+(g-0)*(g-0)+(b-141)*(b-141)<d) {
    d=(r-121)*(r-121)+(g-0)*(g-0)+(b-141)*(b-141);
    t=77;
  }    
  return t;
}
