import java.util.ArrayDeque;

class Tree
{
  //ArrayList<Branch> branches;
  ArrayList<ArrayList<Branch>> branches;
  GiftData data;
  int seed;
  int totalBranchCounter;

  public Tree(GiftData giftData, int baseSeed)
  {
    branches = new ArrayList<ArrayList<Branch>>();
    
    addBranch(createTrunk(1, 0.05f, 0.1f, seed));
    
    totalBranchCounter = 1;
    data = giftData;
    seed = baseSeed;
    
    randomSeed(seed);
  }
  
  public void addBranch(Branch branch)
  {
    if (branch.getTreeHeight()  > branches.size() - 1)
      branches.add(new ArrayList<Branch>());
    
    branches.get(branch.getTreeHeight()).add(branch);
    
    //branches.add(branch);
  }
  
  public void update(int frameCount)
  {
    Branch trunk = branches.get(0).get(0);
    
    if (!data.partitionNext(1.0f / 9000.0f))
      return;
    
    for (int i = 0; i < data.getNumParts(); i++)
    {
      for (int j = 0; j < data.getPartitionSize(i); j++)
      {
        if (random(1.0f) < 0.3f*i / pow(data.getNumParts()+data.getPartitionSize(i), 2))
        {
          //Create new branches
          int treeLevel = floor(map(i, 0, data.getNumParts()-1, 0, branches.size()));
          Branch base = null;
          float basePos = 0.0f;
          if (treeLevel == 0)
          {
            base = trunk;
            basePos = random(0.05f, 0.4f);
          }
          else
          {
            int getIndex = floor(random(branches.get(treeLevel-1).size()));
            //println(getIndex);
            base = branches.get(treeLevel - 1).get(getIndex);
            basePos = random(0.4f, 0.7f);
          }
          
          //println(totalBranchCounter);
          addBranch(new Branch(1, 0.07f, 0.2f, seed + totalBranchCounter, base, basePos, random(-1.0f, 1.0f)));
          totalBranchCounter++;
        }
      }
    }
    
   // println("");
    
    /*for (int i = 0; i < branches.size(); i++)
    {
      for (int j = 0; j < branches.get(i).size(); j++)
      {
        Branch branch = branches.get(i).get(j);
        if (branch.getTreeHeight() != 0)
        {
          try
          {
            println(branch.getBase().getTreeHeight());
          }
          catch (Exception e)
          {
          }
        }
      }
      //println(branches.get(i).size());
    }*/
    //println("");
    //ArrayList<Branch> trunkChildren = branches.get(0).get(0).getChildren();
   // for (Branch branch : trunkChildren)
    //  println(branch.getSeed());
   // println("");
    
    //Grow existing branches
    //Always grow trunk
    float lastAngle = trunk.getTipAngle();
    noiseSeed(trunk.getSeed());
    float angleDiff = 0.08f * (noise(0.08f * frameCount) - 0.5f);
    
    if (random(1.0f) < 0.3f) //make sure trunk stays straight
    {
      lastAngle = clampAngle(lastAngle);
      if (lastAngle > 0.0f && lastAngle < PI)
        angleDiff = -abs(angleDiff);
      else
        angleDiff = abs(angleDiff);
    }

    trunk.addPoint(angleDiff);
    
    //Grow branches more the closer they are to the trunk
    for (ArrayList<Branch> level : branches)
      for (Branch branch : level)
      {
        if (branch.getTreeHeight() > 0 && random(1.0f) < 0.4f / branch.getTreeHeight())
        {
          noiseSeed(branch.getSeed());
          branch.addPoint(0.08f * (noise(0.02f * frameCount) - 0.5f));
        }
      }
  }
  
  public void draw(PGraphics frame, float trunkThickness) throws Exception
  {
    //PVector strips[][] = new PVector[branches.size()][];
    
    //First compute all branches
    for (int i = 0; i < branches.size(); i++)
    {
      ArrayList<Branch> bi = branches.get(i);
      
      for (int j = 0; j < bi.size(); j++)
      {
        Branch branch = bi.get(j);
        
        //println(branch.getTreeHeight());
        
        if (branch.isTrunk())
          branch.generateBranch(trunkThickness, 0.1f);
        else
          branch.generateBranch(0.9f * branch.getBase().getWidth(branch.getPosOnBaseBranch()), 0.1f);
        
        //strips[i] = branch.getBranchStrip();
      }
    }
    
    //Then render them
    ArrayDeque<Branch> drawStack = new ArrayDeque<Branch>();
    drawStack.push(branches.get(0).get(0)); //push trunk
    
    //There is a problem here: only the first branch off the trunk is rendered
    while (true)
    {
      Branch baseBranch = drawStack.peek(); //First pass: baseBranch = trunk. Second pass: baseBranch = firstBranchOffTrunk
      //Third pass: baseBranch = trunk
      
      for (Branch branch : baseBranch.getChildren())
      {
        if (!branch.drawn()) //First pass: branch = first branch off trunk
        {
          frame.pushMatrix();
          branch.transformTo(frame, 0.2f); //DEBUG: implement angle offset (sway)
          drawStack.push(branch);
          break;
        }
      }
      //First pass: drawStack: firstBranchOffTrunk, Trunk
      if (drawStack.peek() == baseBranch) //Either all children have been drawn or there are no children
      {
        baseBranch.draw(frame); //Second pass: jump in here
        drawStack.pop();
        if (drawStack.isEmpty())
          break;
        frame.popMatrix();
      }
    }
    
    branches.get(0).get(0).unsetDrawnRecursive(); //Set the entire tree to undrawn
  }
  
  private float clampAngle(float angle)
  {
    return angle < 0.0f ? (angle+TWO_PI) : (angle > TWO_PI ? (angle-TWO_PI) : angle);
  }
}
