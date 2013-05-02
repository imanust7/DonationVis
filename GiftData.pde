class GiftData
{
  ArrayList<int[]> data;
  ArrayList<ArrayList<int[]>> parts;
  int nump;
  float dataPos;
  int maxEntry;
  
  public GiftData(int numParts)
  {
    data = new ArrayList<int[]>();
  
    String line;
    BufferedReader reader = createReader("giftData");
    
    try
    {
      while(reader.ready())
      {
        String[] first = split(reader.readLine(), TAB);
        String[] date = split(first[0], '/');
        int amount = int(trim(join(split(first[1], ','), "")));
        int day = int(trim(date[0]));
        int month = int(date[1]);
        int year = int(date[2]);
        
        data.add(new int[]{365*(year-8) + 31*month + day, amount});
      }
    }
    catch (IOException e)
    {
      e.printStackTrace();
    }
    
    nump = numParts;
    dataPos = 0.0f;
    maxEntry = getLargestAmt(1.0f);
    
    parts = new ArrayList<ArrayList<int[]>>();
  }
  
  public void partitionWhole(float pos, int numParts)
  {
    nump = numParts;
    int limit = floor(pos * (float)data.size());
    
    parts = new ArrayList<ArrayList<int[]>>();
    for (int i = 0; i < numParts; i++)
      parts.add(new ArrayList<int[]>());
    
    float largestAmt = getLargestAmt(pos);
    
    for (int i = 0; i < limit; i++)
    {
      int amt = data.get(i)[1];
      if (amt == 0)
        continue;
      
      float logAmt = log(amt);
      int partsIndex = floor(numParts*logAmt/log(largestAmt));
      
      if (partsIndex >= numParts)
        partsIndex = numParts - 1;
      
      parts.get(numParts - partsIndex - 1).add(new int[]{i, amt});
    }
    
    //for (int i = 0; i < numParts; i++)
    //  println(parts.get(i).size());
  }
  
  public boolean partitionNext(float stepSize) //assuming 0 < dataLength < 1
  {
    float numEntries = stepSize * data.size();
    if (dataPos + numEntries > data.size() - 1)
    {
      if (dataPos >= data.size() - 1)
        return false;
      numEntries = data.size() - dataPos - 1;
    }
    
    for (int i = 0; i < nump; i++)
      parts.add(new ArrayList<int[]>());
      
    int dataPosWhole = floor(dataPos);
    int numEntriesWhole = floor(numEntries);
    
    for (int i = dataPosWhole; i < dataPosWhole+numEntriesWhole; i++)
    {
      int entry = data.get(i)[1];
      if (entry == 0)
        continue;
      
      float logEntry = log(entry);
      int partsIndex = floor(nump * logEntry/log(maxEntry));
      
      if (partsIndex >= nump)
        partsIndex = nump - 1;
      
      parts.get(nump - partsIndex - 1).add(new int[]{i, entry}); //Small entries go in higher partitions (descending)
    }
    
    dataPos += numEntries;
    return true;
  }
  
  public int getLargestAmt(float pos)
  {
    int largest = 0;
    
    int limit = floor(pos * (float)data.size());
    for (int i = 0; i < limit; i++)
    {
      int amt = data.get(i)[1];
      largest = amt > largest ? amt : largest;
    }
    
    return largest;
  }
  
  public int getLargestAmtP(int level) //P for partitioned
  {
    int largest = 0;
    
    for (int i = 0; i < parts.get(level).size(); i++)
    {
      int amt = parts.get(level).get(i)[1];
      largest = amt > largest ? amt : largest;
    }
    
    return largest;
  }
  
  public float getSum(float pos) //Between 1 and 0, how much of giftData to add up
  {
    float sum = 0.0f;
    
    int limit = floor(pos * (float)data.size());
    for (int i = 0; i < limit; i++)
    {
      sum += data.get(i)[1];
    }
    
    return sum;
  }
  
  public int getPartitionSize(int level)
  {
    return parts.get(level).size();
  }
  
  public int[] getPartitioned(int level, int index)
  {
    return parts.get(level).get(index);
  }
  
  public int getNumParts()
  {
    return nump;
  }
  
  public int getDataSize(float pos)
  {
    return floor(pos * (float)data.size());
  }
}
