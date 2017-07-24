// detection box

import point2line.*;

class DBox {
  int n = 4;                        // number of handles
  Handle[] handles = new Handle[n];
  Vect2[] vertices = new Vect2[n];
  float hsize = 10;

  DBox(float xpos, float ypos, float dsize, DBox[] o) {
    handles[0] = new Handle(xpos - dsize/2, ypos - dsize/2, 0, 0, hsize, handles);
    handles[1] = new Handle(xpos + dsize/2, ypos - dsize/2, 0, 0, hsize, handles);
    handles[2] = new Handle(xpos + dsize/2, ypos + dsize/2, 0, 0, hsize, handles);
    handles[3] = new Handle(xpos - dsize/2, ypos + dsize/2, 0, 0, hsize, handles);

    for (int i = 0; i < handles.length; i++) {
      vertices[i] = new Vect2(handles[i].getX(), handles[i].getY());
    }
  }

  void update() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].update();
    }
  }

  void display() {

    stroke(0);
    beginShape();
    for (int i = 0; i < handles.length; i++) {
      vertex(handles[i].getX(), handles[i].getY());
      vertices [i] = new Vect2(handles[i].getX(), handles[i].getY());
    }
    endShape(CLOSE);
    for (int i = 0; i < handles.length; i++) {
      handles[i].display(i);
    }
  }

  void releaseEvent() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].releaseEvent();
    }
  }

  boolean detect(float x, float y) {
    Vect2 coor = new Vect2(x, y);
    return Space2.insidePolygon(coor, vertices);
  }

  // TO-DO
  int numberOfDetections() {
    return 0;
  }
  float nearestDetection() {
    return 0;
  }
  //coordinates of people in DBox
  float[] getCoordinates() {
    return new float[0];
  }
}

