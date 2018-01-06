class Behavior{
  float xVel, yVel, xthreshhold, ythreshhold, twidth, theight, xcurvefactor, ycurvefactor, speed, redfactor, greenfactor, bluefactor;

  public Behavior() {
    speed = 1;
    if (random(0, 1)<0.5) {
      if (random(0, 1)<0.5) {
        xVel = 1.0;
      } else {
        yVel = 1.0;
      }
    } else {
      xVel = random(0, 1);
      yVel = 1-xVel;
    }

    if (random(0, 1)<0.5) {
      xVel = -xVel;
    }

    if (random(0, 1)<0.5) {
      yVel = -yVel;
    }

    xthreshhold = random(0, width);
    ythreshhold = random(0, height);
    twidth = random(width/8, width * (3.0/4.0))*scalefactor;
    theight = random(height/8, height * (3.0/4.0))*scalefactor;
    xcurvefactor = randomcurvefactor();
    ycurvefactor = randomcurvefactor();

    redfactor = 0;
    greenfactor = 0;
    bluefactor = 0;
    if (random(0, 1)>0.25) {
      float cfactor = random(5, 200);
      if (random(0, 1)<0.3333) {
        redfactor = cfactor;
      } else if (random(0, 1)<0.5) {
        greenfactor = cfactor;
      } else {
        bluefactor = cfactor;
      }
    } else {
      redfactor = random(5, 200);
      bluefactor = random(5, 200);
      greenfactor = random(5, 200);
    }
  }

  public float randomcurvefactor() {
    float curvefactor = random(0.0, 0.002);
    if (random(0, 1)<0.5) {
      curvefactor = 0;
    }
    return curvefactor;
  }

  public boolean collidePos(float x, float y) {
    return x>xthreshhold && x<=xthreshhold+twidth && y>ythreshhold && y<ythreshhold+theight;
  }
  
  public float[] getColorFactors(float x, float y) {
    float midx = xthreshhold + (twidth/2);
    float midy = ythreshhold + (theight/2);
    float halfw = (twidth/2);
    float halfh = theight/2;
    float posfactor = ((halfw-abs(x-midx)) / twidth) + ((halfh-abs(y-midy)) / (theight));
    float r = redfactor * posfactor;
    float g = greenfactor * posfactor;
    float b = bluefactor * posfactor;
    float[] rgb = {r,g,b};
    return rgb;
  }

  public int compareTo(Behavior another) {
    if (this.ythreshhold<another.ythreshhold) {
      return -1;
    } else {
      return 1;
    }
  }
}