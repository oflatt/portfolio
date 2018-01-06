

public class Curve {
  float xpos, ypos, currentRed, currentGreen, currentBlue;
  ArrayList<Behavior> behaviors;
  Behavior defaultBehavior;
  int drawWidth;
  float stuckCounter, stuckPosx, stuckPosy;

  public Curve() {
    behaviors = new ArrayList<Behavior>();
    int numofhitboxes = (int) (8.0/scalefactor);

    for (int i= 0; i<numofhitboxes; i++) {
      Behavior tb = new Behavior();
      behaviors.add(tb);
    }

    defaultBehavior = new Behavior();

    if (defaultBehavior.xVel == 0) {
      defaultBehavior.xVel = defaultBehavior.yVel;
    } else if (defaultBehavior.yVel == 0) {
      defaultBehavior.yVel = defaultBehavior.xVel;
    }
    
    defaultBehavior.xthreshhold = 0;
    defaultBehavior.ythreshhold = 0;
    defaultBehavior.twidth = width;
    defaultBehavior.theight = height;

    drawWidth = (int) (5.0*scalefactor);
    xpos = random(0, width);
    ypos = random(0, height);
    resetStuck();
  }


  public void drawCurve() {
    float fillred, fillgreen, fillblue;
    fillred = max(currentRed-50, 0);
    fillgreen = max(currentGreen-50, 0);
    fillblue = max(currentBlue-50, 0);
    stroke(currentRed, currentGreen, currentBlue);
    fill(fillred, fillgreen, fillblue);
    rect(xpos, ypos, drawWidth, drawWidth);
  }

  public float loopcolor(float c) {
    float newc;
    // if the factor has looped around an even num of times
    if (floor(c/255.0) % 2 == 0.0) {
      newc = c%255;
    } else {
      newc = 255-(c%255);
    }
    return newc;
  }

  public void resetStuck() {
    stuckCounter = 0;
    stuckPosx = xpos;
    stuckPosy = ypos;
  }

  public void iteration() {
    Behavior b = defaultBehavior;
    boolean found = false;
    int i = 0;
    float cred, cgreen, cblue;
    float[] defaultrgb = defaultBehavior.getColorFactors(xpos, ypos);
    cred = defaultrgb[0];
    cblue = defaultrgb[1];
    cgreen = defaultrgb[2];

    while (i< behaviors.size()) {
      Behavior checked = behaviors.get(i);
      if (checked.collidePos(xpos, ypos)) {
        if (!found) {
          b = checked;
          found = true;
        }
        float[] rgb = checked.getColorFactors(xpos, ypos);
        cred += rgb[0];
        cgreen += rgb[1];
        cblue += rgb[2];
      }
      i++;
    }

    currentRed = loopcolor(cred);
    currentGreen = loopcolor(cgreen);
    currentBlue = loopcolor(cblue);

    xpos = xpos + (b.xcurvefactor * xpos + b.xVel)*b.speed;
    ypos = ypos + (b.yVel + ypos * b.ycurvefactor)*b.speed;

    if (xpos>width || xpos<-drawWidth|| ypos>height || ypos<-drawWidth || stuckCounter > 700) {
      if (!mousePressed) {
        xpos = random(0, width);
        ypos = random(0, height);
        resetStuck();
      }
    }

    if (abs(stuckPosx - xpos) + abs(stuckPosy - ypos) < 20) {
      stuckCounter += 1;
    } else {
      resetStuck();
    }
  }
}