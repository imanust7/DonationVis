final int fullSizeX = 3840;
final int fullSizeY = 1154;
final int overSizeX = 7680;
final int overSizeY = 2308;

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
  testBranch2 = new Branch(1, 0.05f, 0.1f, 3);
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
  testBranch.generateBranch(1.0f + 0.009f*frameCount, 0.5f);
  
  //testBranch2
  final int growthSpeed2 = 17; //unit: frames per radius
  between = (float)(frameCount%growthSpeed2) / (growthSpeed2-1);
  numLines = testBranch2.getNumPoints() - 1;
  testBranch2.setRadius((between+numLines) / numLines);
  if (between == 0.0f)
    testBranch2.addPoint(0.08f * (noise(0.02f * frameCount) - 0.5f));
  testBranch2.generateBranch(1.0f + 0.002f*frameCount, 0.5f);
  
  
  //draw
  currentFrame.beginDraw();
  currentFrame.noSmooth();
  currentFrame.noStroke();
  currentFrame.background(255, 0);
 
  PVector[] strip = testBranch.getBranchStrip();
  PVector[] strip2 = testBranch2.getBranchStrip();
  PVector branch2Base = testBranch.getLinePoint(0.3f);
  
  currentFrame.translate(0.0f, overSizeY / 2.0f);
  currentFrame.scale(10.0f);
  
  currentFrame.pushMatrix();
  currentFrame.translate(branch2Base.x, branch2Base.y);
  currentFrame.rotate(0.4f);
  currentFrame.beginShape(TRIANGLE_STRIP);
  for (int k = 0; k < strip2.length; k++)
  {
    color colour = lerpColor(color(76, 61, 59), color(153, 123, 118), (float)k/(strip2.length-1));
    currentFrame.fill(colour);
    currentFrame.vertex(strip2[k].x, strip2[k].y);
  }
  currentFrame.endShape();
  currentFrame.popMatrix();
  
  currentFrame.beginShape(TRIANGLE_STRIP);
  for (int k = 0; k < strip.length; k++)
  {
    color colour = lerpColor(color(76, 61, 59), color(153, 123, 118), (float)k/(strip.length-1));
    currentFrame.fill(colour);
    currentFrame.vertex(strip[k].x, strip[k].y);
  }
  currentFrame.endShape();
  currentFrame.endDraw();
  
  int frameNum = frameCount % frames.length;
  frames[frameNum].beginDraw();
  frames[frameNum].background(255, 0);
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
