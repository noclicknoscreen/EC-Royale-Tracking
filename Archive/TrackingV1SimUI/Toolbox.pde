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
  text(int(frameRate) + " fps", 10, 20);
  popMatrix();
}


void save(int v) {
  data.setFloat("cam[0]X", cam[0].getX());
  data.setFloat("cam[0]Y", cam[0].getY());
  data.setFloat("cam[0]ang", cam[0].getAng());
  data.setFloat("cam[1]X", cam[1].getX());
  data.setFloat("cam[1]Y", cam[1].getY());
  data.setFloat("cam[1]ang", cam[1].getAng());
  data.setFloat("cam[2]X", cam[2].getX());
  data.setFloat("cam[2]Y", cam[2].getY());
  data.setFloat("cam[2]ang", cam[2].getAng());
  for (int id = 0; id < dbox.length; id ++) {
    for (int ihandle = 0; ihandle < 4; ihandle++) {
      saveDBoxHandle(id, ihandle);
    }
  }
  saveJSONObject(data, "data/roomProfile.json");
}

void saveDBoxHandle(int id, int ihandle) {
  data.getJSONArray("dbox")
    .getJSONObject(id)
      .getJSONArray("handlesCoor")
        .getJSONObject(ihandle)
          .setFloat("x", dbox[id].getHandles()[ihandle].getX());
  data.getJSONArray("dbox")
    .getJSONObject(id)
      .getJSONArray("handlesCoor")
        .getJSONObject(ihandle)
          .setFloat("y", dbox[id].getHandles()[ihandle].getY());
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

