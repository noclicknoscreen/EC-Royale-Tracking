// detection box

import point2line.*;

class DBox {
  int n = 4;
  Handle[] handles = new Handle[n];
  Vect2[] vertices = new Vect2[n];
  int hsize = 10;

  DBox(int xpos, int ypos, int dsize) {
    handles[0] = new Handle(xpos - dsize/2, ypos - dsize/2, 0, 0, hsize, handles);
    handles[1] = new Handle(xpos + dsize/2, ypos - dsize/2, 0, 0, hsize, handles);
    handles[2] = new Handle(xpos + dsize/2, ypos + dsize/2, 0, 0, hsize, handles);
    handles[3] = new Handle(xpos - dsize/2, ypos + dsize/2, 0, 0, hsize, handles);

    for (int i = 0; i < handles.length; i++) {
      vertices[i] = new Vect2(handles[i].getX(), handles[i].getY());
    }
  }

  void display() {
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

  void releaseEvent() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].releaseEvent();
    }
  }
}

