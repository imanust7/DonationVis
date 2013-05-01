/*final int fullSizeX = 3840;
final int fullSizeY = 1154;
final int overSizeX = 7680;
final int overSizeY = 2308;*/

final int fullSizeX = 1920;
final int fullSizeY = 577;
final int overSizeX = 1920;
final int overSizeY = 577;

final float previewScale = 0.5f;

PGraphics[] frames;
PGraphics currentFrame;
Branch testBranch, testBranch2;

void setup()
{
  size(floor(fullSizeX*previewScale), floor(fullSizeY*previewScale));
  frameRate(25);
  background(255);
  
  currentFrame = createGraphics(overSizeX, overSizeY);
  frames = new PGraphics[5];
  for (int i = 0; i < frames.length; i++)
  {
    frames[i] = createGraphics(fullSizeX, fullSizeY);
  }
  
  testBranch = new Branch(1, 0.05f, 0.1f, 2);
  testBranch2 = new Branch(1, 0.05f, 0.1f, 5);
}

void draw()
{
  background(255);
  
  //update
  //testBranch
  final int growthSpeed = 10; //unit: frames per radius
  float between = (float)(frameCount%growthSpeed) / (growthSpeed-1);
  int numLines = testBranch.getNumPoints() - 1;
  testBranch.setRadius((between+numLines) / numLines);
  if (between == 0.0f)
    testBranch.addPoint(0.08f * (noise(0.02f * frameCount) - 0.5f));
  testBranch.generateBranch(1.0f + 0.001f*frameCount, 0.5f);
  
  //testBranch2
  final int growthSpeed2 = 13; //unit: frames per radius
  between = (float)(frameCount%growthSpeed2) / (growthSpeed2-1);
  numLines = testBranch2.getNumPoints() - 1;
  testBranch2.setRadius((between+numLines) / numLines);
  if (between == 0.0f)
    testBranch2.addPoint(0.08f * (noise(0.02f * frameCount) - 0.5f));
  testBranch2.generateBranch(1.0f + 0.001f*frameCount, 1.0f);
  
  
  //draw
  currentFrame.beginDraw();
  currentFrame.background(0, 0);
  currentFrame.noStroke();
  
  currentFrame.translate(0.0f, overSizeY / 2.0f);
  currentFrame.scale(10.0f);
  
  PVector[] strip = testBranch.getBranchStrip();
  currentFrame.noSmooth();
  currentFrame.beginShape(TRIANGLE_STRIP);
  for (int k = 0; k < strip.length; k++)
  {
    color colour = lerpColor(color(76, 61, 59), color(153, 123, 118), (float)k/(strip.length-1));
    currentFrame.fill(colour);
    currentFrame.vertex(strip[k].x, strip[k].y);
  }
  currentFrame.endShape();
  
  /*frames[currentFrame].strokeWeight(1.5f);
  frames[currentFrame].noFill();
  frames[currentFrame].smooth();
  frames[currentFrame].beginShape();
  for (int k = 0; k < strip.length; k++)
  {
    color colour = lerpColor(color(76, 61, 59), color(153, 123, 118), (float)k/(strip.length-1));
    frames[currentFrame].stroke(colour);
    frames[currentFrame].vertex(strip[k].x, strip[k].y);
  }
  frames[currentFrame].endShape();
  frames[currentFrame].noStroke();*/
  currentFrame.endDraw();
  
  int frameNum = frameCount % frames.length;
  frames[frameNum].beginDraw();
  frames[frameNum].image(currentFrame, 0, 0, fullSizeX, fullSizeY);
  frames[frameNum].endDraw();
  image(frames[frameNum], 0, 0, width, height);
  
  
  if (frameNum == frames.length-1)
  {
    writeFrames();
  }
}

void writeFrames()
{
  int base = frameCount - frames.length + 1;
  
  /*for (int i = 0; i < frames.length; i++)
  {
    frames[i].save("ani/frame" + nf(base + i, 5) + ".png");
    if (i % 4 == 0)
      print(".");
  }
  
  println("");*/
}

void keyPressed()
{
  for (int i = 0; i < frames.length; i++)
    frames[i].save("ani/frame" + nf(i, 5) + ".png");
    
  exit();
}
