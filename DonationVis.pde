final int fullSizeX = 3840;
final int fullSizeY = 1154;
final int overSizeX = 7680;
final int overSizeY = 2308;

final float previewScale = 0.5f;

PGraphics[] frames;
PGraphics currentFrame;
Tree testTree;
GiftData data;

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
  
  data = new GiftData(7);
  
  testTree = new Tree(data, 87);
}

void draw()
{
  background(255);
  
  //update
  testTree.update(frameCount);
  
  
  //draw
  currentFrame.beginDraw();
  currentFrame.background(255, 0);
  
  currentFrame.translate(0.0f, overSizeY / 2.0f);
  currentFrame.scale(10.0f);
  try
  {
    testTree.draw(currentFrame, 0.5f + 0.03f*frameCount);
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
