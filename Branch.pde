class Branch
{
  //PVector[] linePoints;
  //Float[] lineAngles;
  //ArrayList<PVector> linePoints;
  final PVector initialPos;
  ArrayList<Float> lineAngles;
  PVector[] branchStrip;
  float radius;
 // PVector[] branchLines;
  
  //0 < straightness < 1, noise is Perlin noise multiplier
  public Branch(int numPoints, float noiseAmt, float noiseScale, int seed)
  {
    radius = 1.0f;
    initialPos = new PVector(0.0f, 0.0f);
    
    //linePoints = new ArrayList<PVector>();
    lineAngles = new ArrayList<Float>();
    //linePoints.add(p0);
    lineAngles.add(0.0f);
    
    noiseSeed(seed);
    
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
  
  /*public Branch(final PVector[] lp)
  {
    linePoints = lp;
    generateBranch(1.0f, 0.0f);
  }*/
  
  public void addPoint(float relAngle)
  {
    float newAngle = lineAngles.get(lineAngles.size()-1) + relAngle;
    //PVector lastPoint = linePoints.get(linePoints.size()-1);
    
    //linePoints.add(new PVector(lastPoint.x + radius*cos(newAngle), lastPoint.y + radius*sin(newAngle)));
    lineAngles.add(newAngle);
  }
  
  public void generateBranch(float startThickness, float endThickness)
  {
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
  
  public void setRadius(float newRadius)
  {
    radius = newRadius;
  }
  
  public PVector[] getBranchStrip()
  {
    //PVector[] points = new PVector[branchStrip.length];
    
    //for (int i = 0; i < branchStrip.length; i++)
    //  points[i] = new PVector(branchStrip[i].x, branchStrip[i].y);
      
    //return points;
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
  
  /*public float getWidth(float pos)
  {
    return lerp(startThickness, endThickness, pos);
  }*/
  
  private float clampAngle(float angle)
  {
    return angle < 0.0f ? (angle+TWO_PI) : (angle > TWO_PI ? (angle-TWO_PI) : angle);
  }
}
