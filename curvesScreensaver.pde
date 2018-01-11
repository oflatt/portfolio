Curve curve1;
boolean paused;
float scalefactor;

void setup()
{
  scalefactor = 0.2;
  background(235, 235, 235);
  size(window.innerWidth, window.innerHeight);
  fill(0, 0, 0);
  text("Press space to pause and c to clear", 10, 10);
  curve1 = new Curve();
  frameRate(60);
  paused = false;
  fill(255,255,255);
}

void draw()
{
  if (!paused) {
    for (int x = 0; x<15; x++) {
      curve1.iteration();
      curve1.drawCurve();
    }
  }
  if (mousePressed) {
    curve1.xpos = mouseX;
    curve1.ypos = mouseY;
    if (paused) {
      for (int x = 0; x<10; x++) {
        curve1.iteration();
        curve1.drawCurve();
      }
    }
  }
}

void keyReleased() {
  if (key == 'c' || key == 'C') {
    background(235, 235, 235);
  } else if (key == ' ') {
    paused = !paused;
  }
}