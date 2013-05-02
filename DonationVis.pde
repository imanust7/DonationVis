final int fullSizeX = 3840;
final int fullSizeY = 1154;
final int overSizeX = 7680;
final int overSizeY = 2308;

final float previewScale = 0.5f;

PGraphics[] frames;
PGraphics currentFrame;
Branch[] testBranch;
Tree testTree;

void setup()
{
  size(floor(fullSizeX*previewScale), floor(fullSizeY*previewScale));
  frameRate(25);
  background(255);
  
  currentFrame = createGraphics(overSizeX, overSizeY);
  currentFrame.beginDraw();
  currentFrame.noSmooth();
  currentFrame.noStroke();
  currentFrame.endDraw();
  frames = new PGraphics[5];
  for (int i = 0; i < frames.length; i++)
  {
    frames[i] = createGraphics(fullSizeX, fullSizeY);
    frames[i].beginDraw();
    frames[i].noStroke();
    frames[i].endDraw();
  }
  
  testBranch = new Branch[6];
  testBranch[0] = createTrunk(1, 0.05f, 0.1f, 6);
  testBranch[1] = new Branch(1, 0.05, 0.1f, 7, testBranch[0], 0.5f, 0.07f);
  testBranch[2] = new Branch(1, 0.05, 0.1f, 7, testBranch[0], 0.2f, 0.07f);
  testBranch[3] = new Branch(1, 0.05, 0.1f, 7, testBranch[1], 0.3f, 0.07f);
  testBranch[4] = new Branch(1, 0.05, 0.1f, 7, testBranch[3], 0.3f, 0.07f);
  testBranch[5] = new Branch(1, 0.05, 0.1f, 7, testBranch[4], 0.3f, 0.07f);
  
  testTree = new Tree();
  testTree.addBranch(testBranch[0]);
  testTree.addBranch(testBranch[1]);
  testTree.addBranch(testBranch[2]);
  testTree.addBranch(testBranch[3]);
  testTree.addBranch(testBranch[4]);
  testTree.addBranch(testBranch[5]);
}

void draw()
{
  background(255);
  
  //update
  for (int i = 0; i < testBranch.length; i++)
  {
    final int growthSpeed = 10; //unit: frames per radius
    float between = (float)(frameCount%growthSpeed) / (growthSpeed-1);
    int numLines = testBranch[i].getNumPoints() - 1;
    
    testBranch[i].setRadius((between+numLines) / numLines);
    if (between == 0.0f)
      testBranch[i].addPoint(0.08f * (noise(0.02f * frameCount) - 0.5f));
  }
  
  //draw
  currentFrame.beginDraw();
  currentFrame.background(255, 0);
  
  currentFrame.translate(0.0f, overSizeY / 2.0f);
  currentFrame.scale(10.0f);
  try
  {
    testTree.draw(currentFrame, 1.0f + 0.009f*frameCount);
  }
  catch (Exception e)
  {
    e.printStackTrace();
    println(e.getMessage());
  }
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
