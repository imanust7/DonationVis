class Branch
{
  //PVector[] linePoints;
  //Float[] lineAngles;
  //ArrayList<PVector> linePoints;
  final PVector initialPos;
  ArrayList<Float> lineAngles;
  PVector[] branchStrip;
  float radius;
  Branch base;
  float basePos;
  color baseColour, tipColour;
  ArrayList<Branch> children;
  boolean drawn;
  float angle;
  boolean trunk;
  int seed;
  float currentStartThickness, currentEndThickness;
 // PVector[] branchLines;
  
  //0 < straightness < 1, noise is Perlin noise multiplier
  public Branch(int numPoints, float noiseAmt, float noiseScale, int perlinSeed, Branch baseBranch, float baseBranchPos, float initialAngle) //Angle relative to base branch
  {
    radius = 1.0f;
    initialPos = new PVector(0.0f, 0.0f);
    base = baseBranch;
    if (base == null)
      trunk = true;
    else
    {
      trunk = false;
      base.addChild(this);
    }
    basePos = baseBranchPos;
    drawn = false;
    angle = initialAngle;
    baseColour = color(76, 61, 59);
    tipColour = color(153, 123, 118);
    currentStartThickness = -1.0f;
    currentEndThickness = -1.0f;
    seed = perlinSeed;
    
    children = new ArrayList<Branch>();
    lineAngles = new ArrayList<Float>();
    lineAngles.add(0.0f);
    
    noiseSeed(perlinSeed);
    
    for (int i = 0; i < numPoints; i++)
    {
      //PVector lastPoint = linePoints.get(linePoints.size()-1);
      float lastAngle = lineAngles.get(lineAngles.size()-1);
      float newAngle;
      float angleDiff = noiseAmt*(noise(noiseScale * i) - 0.5f);
      
      /*if (random(1.0f) < straightness)
      {
        //Make sure newAngle moves up not down
        lastAngle = clampAngle(lastAngle);
        if (lastAngle > HALF_PI && lastAngle < 1.5f*PI)
          angleDiff = abs(angleDiff);
        else
          angleDiff = -abs(angleDiff);
      }*/
      
      newAngle = lastAngle + angleDiff;
      
      //linePoints.add(new PVector(lastPoint.x + radius*cos(newAngle), lastPoint.y + radius*sin(newAngle)));
      lineAngles.add(newAngle);
    }
  }
  
  public void addPoint(float relAngle)
  {
    float newAngle = lineAngles.get(lineAngles.size()-1) + relAngle;
    //PVector lastPoint = linePoints.get(linePoints.size()-1);
    
    //linePoints.add(new PVector(lastPoint.x + radius*cos(newAngle), lastPoint.y + radius*sin(newAngle)));
    lineAngles.add(newAngle);
  }
  
  public void generateBranch(float startThickness, float endThickness)
  {
    currentStartThickness = startThickness;
    currentEndThickness = endThickness;
    
    PVector pOld = initialPos;
    PVector pCurrent = new PVector(pOld.x + radius*cos(lineAngles.get(0)), pOld.y + radius*sin(lineAngles.get(0)));
    PVector pNew = new PVector(pCurrent.x + radius*cos(lineAngles.get(1)), pCurrent.y + radius*sin(lineAngles.get(1)));
    
    branchStrip = new PVector[2 * getNumPoints()];
    
    PVector diff = PVector.sub(pCurrent, pOld);
    diff.normalize();
    diff = new PVector(-diff.y, diff.x);
    branchStrip[0] = PVector.add(pOld, PVector.mult(diff, startThickness));
    branchStrip[1] = PVector.sub(pOld, PVector.mult(diff, startThickness));
    
    for (int i = 1; i < getNumPoints() - 1; i++)
    {
      float thickness = map((float)i/(getNumPoints()-1), 0.0f, 1.0f, startThickness, endThickness);
      PVector pTemp = new PVector(pNew.x, pNew.y);
      pNew.add(new PVector(radius*cos(lineAngles.get(i+1)), radius*sin(lineAngles.get(i+1))));
      pCurrent = pTemp;
      pOld = pCurrent;
      
      diff = PVector.sub(pNew, pOld);
      diff.normalize();
      diff = new PVector(-diff.y, diff.x);
      branchStrip[2*i] = PVector.add(pCurrent, PVector.mult(diff, thickness));
      branchStrip[2*i + 1] = PVector.sub(pCurrent, PVector.mult(diff, thickness));
    }
    
    PVector pTemp = new PVector(pNew.x, pNew.y);
    pNew.add(new PVector(radius * cos(lineAngles.get(getNumPoints()-1)), radius * sin(lineAngles.get(getNumPoints()-1))));
    pCurrent = pTemp;
    pOld = pCurrent;
    
    diff = PVector.sub(pNew, pCurrent);
    diff.normalize();
    diff = new PVector(-diff.y, diff.x);
    branchStrip[2*getNumPoints() - 2] = PVector.add(pNew, PVector.mult(diff, endThickness));
    branchStrip[2*getNumPoints() - 1] = PVector.sub(pNew, PVector.mult(diff, endThickness));
  }
  
  public void addChild(Branch branch)
  {
    children.add(branch);
  }
  
  public void unsetDrawnRecursive()
  {
    drawn = false;
    
    for (Branch branch : children)
      branch.unsetDrawnRecursive();
  }
  
  public boolean drawn()
  {
    return drawn;
  }
  
  public ArrayList<Branch> getChildren()
  {
    return children;
  }
  
  public void transformTo(PGraphics frame, float angleOffset)
  {
    if (!trunk)
    {
      PVector branchBase = base.getLinePoint(basePos);
      frame.translate(branchBase.x, branchBase.y);
      frame.rotate(angle + angleOffset);
    }
  }
  
  public float getPosOnBaseBranch()
  {
    return basePos;
  }
  
  public void draw(PGraphics frame)
  {
    frame.beginShape(TRIANGLE_STRIP);
    for (int k = 0; k < branchStrip.length; k++)
    {
      color colour = lerpColor(baseColour, tipColour, (float)k/(branchStrip.length-1));
      currentFrame.fill(colour);
      currentFrame.vertex(branchStrip[k].x, branchStrip[k].y);
    }
    frame.endShape();
    
    drawn = true;
  }
  
  public void setRadius(float newRadius)
  {
    radius = newRadius;
  }
  
  public PVector[] getBranchStrip()
  {
    return branchStrip;
  }
  
  public PVector getLinePoint(float pos) //0 < pos < 1
  {
    int index = floor(pos * lineAngles.size());
    
    if (index > lineAngles.size() - 1)
      index = lineAngles.size() - 1;
    
    return PVector.lerp(branchStrip[2*index], branchStrip[2*index + 1], 0.5f);
  }
  
  public float getLineAngle(float pos) //0 < pos < 1
  {
    int index = floor(pos * lineAngles.size());
    
    if (index > lineAngles.size() - 1)
      index = lineAngles.size() - 1;
    
    return lineAngles.get(index);
  }
  
  public int getNumPoints()
  {
    return lineAngles.size();
  }
  
  public float getWidth(float pos) throws Exception //0 < pos < 1
  {
    if (currentStartThickness < 0.0f)
      throw new Exception("The branch must be generated at least once before getWidth(float) is called.");
    
    return lerp(currentStartThickness, currentEndThickness, pos);
  }
  
  public void setBaseColour(color colour)
  {
    baseColour = colour;
  }
  
  public void setTipColour(color colour)
  {
    tipColour = colour;
  }
  
  public Branch getBase() throws Exception
  {
    if (trunk)
      throw new Exception("Tried to get base of trunk. Does not exist.");
    return base;
  }
  
  public boolean isTrunk()
  {
    return trunk;
  }
  
  public int getSeed() //DEBUG
  {
    return seed;
  }
  
  private float clampAngle(float angle)
  {
    return angle < 0.0f ? (angle+TWO_PI) : (angle > TWO_PI ? (angle-TWO_PI) : angle);
  }
}

Branch createTrunk(int numPoints, float noiseAmt, float noiseScale, int seed)
{
  return new Branch(numPoints, noiseAmt, noiseScale, seed, null, 0.0f, 0.0f);
}
