Curve curve1;
boolean paused;
float scalefactor;
int pixel, buttonwidth, rectsize;

void setup()
{
  scalefactor = 0.2;
  background(255, 255, 255);
  size(800,800); //size(window.innerWidth-50, window.innerHeight-50);
  surface.setResizable(true);
  fill(0, 0, 0);
  text("Press space to pause and c to clear", 10, 10);
  curve1 = new Curve();
  frameRate(60);
  paused = false;
  fill(255,255,255);
  pixel = round((height/500));
  buttonwidth = pixel*12;
  rectsize = 1;
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
  float yoffset = pixel*2;
  float pluswidth = pixel*2;
  stroke(100,100,100);
  fill(100,100,100);
  if(overButton(0)){
    stroke(0,0,0);
    fill(0,0,0);
  }
  rect(width-buttonwidth-pixel*2,yoffset,buttonwidth,buttonwidth);
  stroke(255,255,255);
  fill(255,255,255);
  rect(width-buttonwidth-pixel*2 + pixel*2, yoffset + buttonwidth/2 - pluswidth/2, buttonwidth-pixel*4, pluswidth);
  rect(width-buttonwidth-pixel*2 + buttonwidth/2 - pluswidth/2, yoffset+pixel*2, pluswidth, buttonwidth-pixel*4);
  
  yoffset += pixel * 2 + buttonwidth;
  stroke(100,100,100);
  fill(100,100,100);
  if(overButton(buttonwidth+pixel*2)){
    stroke(0,0,0);
    fill(0,0,0);
  }
  rect(width-buttonwidth-pixel*2,yoffset,buttonwidth,buttonwidth);
  stroke(255,255,255);
  fill(255,255,255);
  rect(width-buttonwidth-pixel*2 + pixel*2, yoffset + buttonwidth/2 - pluswidth/2, buttonwidth-pixel*4, pluswidth);
}

void keyReleased() {
  if (key == 'c' || key == 'C') {
    background(235, 235, 235);
  } else if (key == ' ') {
    paused = !paused;
  }
}

boolean overButton(int yoffset) {
  return mouseX >= width-buttonwidth-pixel*2 && mouseY >= pixel*2+yoffset && mouseX <= width-buttonwidth-pixel*2+buttonwidth &&  mouseY <= pixel*2 + buttonwidth+yoffset;
}

void mouseReleased() {
  if(overButton(0)) {
    rectsize += 1;
  } if(overButton(buttonwidth+pixel*2)){
    if (rectsize > 1){
      rectsize -= 1;
    }
  }
}