import java.util.ArrayDeque;

class Tree
{
  //ArrayList<ArrayList<Branch>> branches;
  ArrayList<Branch> branches;

  public Tree()
  {
    branches = new ArrayList<Branch>();
  }
  
  public void addBranch(Branch branch)
  {
    /*for (int i = 0; i < branches.size(); i++)
      for (int j = 0; j < branches.get(i).size(); j++)
      {
        if (branches.get(i).get(j) == branch.getBase())
        {
          if (i == branches.size() - 1)
            branches.add(new ArrayList<Branch>());
          
          branches.get(i+1).add(branch);
        }
        
        break;
      }*/
    
    branches.add(branch);
  }
  
  public void draw(PGraphics frame, float trunkThickness) throws Exception
  {
    PVector strips[][] = new PVector[branches.size()][];
    
    //First compute all branches
    /*for (int i = 0; i < branches.size(); i++)
    {
      ArrayList<Branch> bi = branches.get(i);
      strips[i] = new PVector[][bi.size()];
      
      for (int j = 0; j < bi.size(); j++)
      {
        bi.get(j).generateBranch(9999999.0f, 1.0f);
        strips[i][j] = bi.get(j).getBranchStrip();
      }
    }*/
    for (int i = 0; i < branches.size(); i++)
    {
      Branch branch = branches.get(i);
      
      if (branch.isTrunk())
      {
        branch.generateBranch(trunkThickness, 0.1f);
        strips[i] = branch.getBranchStrip();
      }
      else
      {
        branch.generateBranch(0.8f * branch.getBase().getWidth(branch.getPosOnBaseBranch()), 0.1f);
        strips[i] = branch.getBranchStrip();
      }
    }
    
    //Then render them
    ArrayDeque<Branch> drawStack = new ArrayDeque<Branch>();
    drawStack.push(branches.get(0)); //push trunk
    
    while (true)
    {
      Branch baseBranch = drawStack.peek();
      
      for (Branch branch : baseBranch.getChildren())
      {
        if (!branch.drawn())
        {
          frame.pushMatrix();
          branch.transformTo(frame, 0.0f); //DEBUG: implement angle offset (sway)
          drawStack.push(branch);
        }
        break;
      }
      
      if (drawStack.peek() == baseBranch) //Either all children have been drawn or there are no children
      {
        baseBranch.draw(frame);
        drawStack.pop();
        if (drawStack.isEmpty())
          break;
        frame.popMatrix();
      }
      
      /*if (baseBranch.getChildren().size() == 0)
      {
        baseBranch.draw(frame);
        drawStack.pop();
        frame.popMatrix();
      }
      else
      {
        for (Branch branch : baseBranch.getChildren())
        {
          if (!branch.drawn())
          {
            frame.pushMatrix();
            branch.transformTo(frame, 0.0f); //DEBUG: implement angle offset (sway)
            drawStack.push(branch);
          }
          break;
        }
      }*/
    }
    
    branches.get(0).unsetDrawnRecursive(); //Set the entire tree to undrawn
  }
}

/*public void renderUpTree(PGraphics frame, ArrayList<Branch> children)
{
  for (Branch child : children)
  {
    frame.pushMatrix();
    
    
    renderUpTree(child.getChildren());
  }
}*/
