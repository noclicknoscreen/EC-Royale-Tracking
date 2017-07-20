import point2line.*;
Handle[] handles;
Vect2[] vertices = new Vect2[4];
int n = 4;

void setup() {
  size(640, 360);
  handles = new Handle[n];
  int hsize = 10;
  handles[0] = new Handle(width/2 -50, height/2 -50, 0, 0, 10, handles);
  handles[1] = new Handle(width/2 +50, height/2 -50, 0, 0, 10, handles);
  handles[2] = new Handle(width/2 +50, height/2 +50, 0, 0, 10, handles);
  handles[3] = new Handle(width/2 -50, height/2 +50, 0, 0, 10, handles);
  for (int i = 0; i < handles.length; i++) {
    vertices[i] = new Vect2(handles[i].getX(), handles[i].getY());
  }
}

void draw() {
  background(153);

  for (int i = 0; i < handles.length; i++) {
    handles[i].update();
    handles[i].display();
  }

  Vect2 mouse = new Vect2( mouseX, mouseY );
  boolean isInside = Space2.insidePolygon(mouse, vertices);

  // display //
  if ( isInside ) fill( 255, 255, 255, 20 );
  else fill( 255, 255, 255, 120 );
  stroke(0);
  beginShape();
  for (int i = 0; i < handles.length; i++) {
    vertex(handles[i].getX(), handles[i].getY());
    vertices [i] = new Vect2(handles[i].getX(), handles[i].getY());
  }
  endShape(CLOSE);
}

void mouseReleased() {
  for (int i = 0; i < handles.length; i++) {
    handles[i].releaseEvent();
  }
}

