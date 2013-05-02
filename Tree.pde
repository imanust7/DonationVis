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
    branches.add(branch);
  }
  
  public void draw(PGraphics frame, float trunkThickness) throws Exception
  {
    PVector strips[][] = new PVector[branches.size()][];
    
    //First compute all branches
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
        branch.generateBranch(0.9f * branch.getBase().getWidth(branch.getPosOnBaseBranch()), 0.1f);
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
          branch.transformTo(frame, 0.2f); //DEBUG: implement angle offset (sway)
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
    }
    
    branches.get(0).unsetDrawnRecursive(); //Set the entire tree to undrawn
  }
}
