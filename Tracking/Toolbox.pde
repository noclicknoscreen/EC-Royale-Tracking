/*******************************************************************************************
 *
 *                                  TOOLBOX
 *                        MISCELLANEOUS FUNCTIONS FOR VARIOUS PURPOSES
 *
 *   Index :
 *
 *
 *******************************************************************************************/

void displayFramerate() {
  pushMatrix();
  fill(#FFFFFF);
  textSize(14);
  text(int(frameRate) + " fps", 180, 26);
  popMatrix();
}


Numberbox ang0;
Numberbox pos0x;
Numberbox pos0y;
Numberbox ang1;
Numberbox pos1x;
Numberbox pos1y;
Numberbox ang2;
Numberbox pos2x;
Numberbox pos2y;
Numberbox ang3;
Numberbox pos3x;
Numberbox pos3y;


void setupControl() {
  pos0x = cp5.addNumberbox("pos0x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(30 + 70 + 30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(int(cam[0].getX_init()))
              ;
  pos0y = cp5.addNumberbox("pos0y")
    .setSize(70, 20)
      .setRange(0, roomHeight+200)
        .setPosition(30+ 70 +30 +70 +30, 40)
          .setValue(int(cam[0].getY_init()))
            ;
  ang0 = cp5.addNumberbox("ang0")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(int(degrees(cam[0].getAng_init())))
              ;
  makeEditable(pos0x);
  makeEditable(pos0y);
  makeEditable(ang0);
  ang0.getValueLabel().setText(str(int(degrees(cam[0].getAng()))));

  if (ncam>1) {
    pos1x = cp5.addNumberbox("pos1x")
      .setSize(70, 20)
        .setRange(0, roomWidth)
          .setPosition(640/2+30 + 70 + 30, 40)
            .setDirection(Controller.HORIZONTAL)
              .setValue(int(cam[1].getX_init()))
                ;
    pos1y = cp5.addNumberbox("pos1y")
      .setSize(70, 20)
        .setRange(0, roomHeight+200)
          .setPosition(640/2+30+ 70 +30 +70 +30, 40)
            .setValue(int(cam[1].getY_init()))
              ;
    ang1 = cp5.addNumberbox("ang1")
      .setSize(70, 20)
        .setRange(0, 360)
          .setPosition(640/2 + 30, 40)
            .setDirection(Controller.HORIZONTAL)
              .setValue(int(degrees(cam[1].getAng_init())))
                ;
    makeEditable(pos1x);
    makeEditable(pos1y);
    makeEditable(ang1);
    ang1.getValueLabel().setText(str(int(degrees(cam[1].getAng()))));
  }

  if (ncam>2) {
    pos2x = cp5.addNumberbox("pos2x")
      .setSize(70, 20)
        .setRange(0, roomWidth)
          .setPosition(30 + 70 + 30, 2*40)
            .setDirection(Controller.HORIZONTAL)
              .setValue(int(cam[2].getX_init()))
                ;
    pos2y = cp5.addNumberbox("pos2y")
      .setSize(70, 20)
        .setRange(0, roomHeight+200)
          .setPosition(30+ 70 +30 +70 +30, 2* 40)
            .setValue(int(cam[2].getY_init()))
              ;
    ang2 = cp5.addNumberbox("ang2")
      .setSize(70, 20)
        .setRange(0, 360)
          .setPosition(30, 2* 40)
            .setDirection(Controller.HORIZONTAL)
              .setValue(int(degrees(cam[2].getAng_init())))
                ;
    makeEditable(pos2x);
    makeEditable(pos2y);
    makeEditable(ang2);
    ang2.getValueLabel().setText(str(int(degrees(cam[2].getAng()))));
  }

  if (ncam>3) {

    pos3x = cp5.addNumberbox("pos3x")
      .setSize(70, 20)
        .setRange(0, roomWidth)
          .setPosition(640/2+30 + 70 + 30, 2*40)
            .setDirection(Controller.HORIZONTAL)
              .setValue(int(cam[3].getX_init()))
                ;
    pos3y = cp5.addNumberbox("pos3y")
      .setSize(70, 20)
        .setRange(0, roomHeight+200)
          .setPosition(640/2+30 + 70 + 30 +70 +30, 2*40)
            .setValue(int(cam[3].getY_init()))
              ;
    ang3 = cp5.addNumberbox("ang3")
      .setSize(70, 20)
        .setRange(0, 360)
          .setPosition(640/2+30, 2*40)
            .setDirection(Controller.HORIZONTAL)
              .setValue(int(degrees(cam[3].getAng_init())))
                ;
    makeEditable(pos3x);
    makeEditable(pos3y);
    makeEditable(ang3);
    ang3.getValueLabel().setText(str(int(degrees(cam[3].getAng()))));
  }

  cp5.addButton("save")
    .setPosition(30, 10)
      .setSize(140, 20)
        ;
}


void pos0x(int v) {
  cam[0].setX(v);
}
void pos0y(int v) {
  cam[0].setY(v);
}
void ang0(int v) {
  cam[0].setAng(radians(v));
}

void pos1x(int v) {
  if (ncam>1) {
    cam[1].setX(v);
  }
}
void pos1y(int v) {
  if (ncam>1) {
    cam[1].setY(v);
  }
}
void ang1(int v) {
  if (ncam>1) {
    cam[1].setAng(radians(v));
  }
}
void pos2x(int v) {
  if (ncam>2) {
    cam[2].setX(v);
  }
}
void pos2y(int v) {
  if (ncam>2) {
    cam[2].setY(v);
  }
}
void ang2(int v) {
  if (ncam>2) {
    cam[2].setAng(radians(v));
  }
}

void pos3x(int v) {
  if (ncam>3) {
    cam[3].setX(v);
  }
}
void pos3y(int v) {
  if (ncam>3) {
    cam[3].setY(v);
  }
}
void ang3(int v) {
  if (ncam>3) {
    cam[3].setAng(radians(v));
  }
}




void save(int v) {
  for (int i=0; i<ncam; i++) {
    data.getJSONArray("cam")
      .getJSONObject(i)
        .setFloat("x", cam[i].getX());
    data.getJSONArray("cam")
      .getJSONObject(i)
        .setFloat("y", cam[i].getY());
    data.getJSONArray("cam")
      .getJSONObject(i)
        .setFloat("ang", cam[i].getAng());
  }
  for (int id = 0; id < dbox.length; id ++) {
    for (int ihandle = 0; ihandle < 4; ihandle++) {
      data.getJSONArray("dbox")
        .getJSONObject(id)
          .getJSONArray("handlesCoor")
            .getJSONObject(ihandle)
              .setFloat("x", allHandles[id*4 + ihandle].getX());
      data.getJSONArray("dbox")
        .getJSONObject(id)
          .getJSONArray("handlesCoor")
            .getJSONObject(ihandle)
              .setFloat("y", allHandles[id*4 + ihandle].getY());
    }
  }
  saveJSONObject(data, "data/roomProfile.json");
}

// function that will be called when controller 'numbers' changes
public void numbers(float f) {
  println("received "+f+" from Numberbox numbers ");
}

void makeEditable( Numberbox n ) {
  // allows the user to click a numberbox and type in a number which is confirmed with RETURN
  final NumberboxInput nin = new NumberboxInput( n ); // custom input handler for the numberbox
  // control the active-status of the input handler when releasing the mouse button inside 
  // the numberbox. deactivate input handler when mouse leaves.
  n.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( true );
    }
  }
  ).onLeave(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( false ); 
      nin.submit();
    }
  }
  );
}


// input handler for a Numberbox that allows the user to 
// key in numbers with the keyboard to change the value of the numberbox

public class NumberboxInput {

  String text = "";
  Numberbox n;
  boolean active;


  NumberboxInput(Numberbox theNumberbox) {
    n = theNumberbox;
    registerMethod("keyEvent", this );
  }

  public void keyEvent(KeyEvent k) {
    // only process key event if input is active 
    if (k.getAction()==KeyEvent.PRESS && active) {
      if (k.getKey()=='\n') { // confirm input with enter
        submit();
        return;
      } else if (k.getKeyCode()==BACKSPACE) { 
        text = text.isEmpty() ? "":text.substring(0, text.length()-1);
        //text = ""; // clear all text with backspace
      } else if (k.getKey()<255) {
        // check if the input is a valid (decimal) number
        final String regex = "\\d+([.]\\d{0,2})?";
        String s = text + k.getKey();
        if ( java.util.regex.Pattern.matches(regex, s ) ) {
          text += k.getKey();
        }
      }
      n.getValueLabel().setText(this.text);
    }
  }

  public void setActive(boolean b) {
    active = b;
    if (active) {
      n.getValueLabel().setText("");
      text = "";
    }
  }

  public void submit() {
    if (!text.isEmpty()) {
      n.setValue( float( text ) );
      text = "";
    } else {
      n.getValueLabel().setText(""+n.getValue());
    }
  }
}

