class Manager{
	int numAddrs;
	int numBlocks;
	Address[] addrs;
	ArrayList flows;
	Block[] blocks;
	XML[] blockXMLs;
	int flowTime = 3000;
	int currentBlockIndex = 0;
	int startTime;


	Manager(XML bitcoinXML){
		numAddrs  = bitcoinXML.getInt("NumAddrs" );
		addrs  = new Address[numAddrs];
		for (int i=0; i<numAddrs; i++){
		    addrs[i] = new Address(i);
		}

		blockXMLs = bitcoinXML.getChildren();
		numBlocks = blockXMLs.length;
		blocks = new Block[numBlocks];
		for (int i=0; i<numBlocks; i++){
			blocks[i] = new Block(this, blockXMLs[i]);
		}

		flows  = new ArrayList();	
	}

	void addBlock(){
		blocks[currentBlockIndex].addFlows();
		currentBlockIndex++;
	}

	void giveBitcoins(int pos, int amt){
		if (pos != -1){
			addrs[pos].addBitcoins(amt);
		}
	}

	void addFlow(int srcPos, int dstPos, int amt){
		Address srcAddr, dstAddr;
		if (srcPos == -1){
			srcAddr = null;
		} else {
			srcAddr = addrs[srcPos];
		}

		if (dstPos == -1){
			dstAddr = null;
		} else {
			dstAddr = addrs[dstPos];
		}

		Flow newFlow = new Flow(srcAddr, dstAddr, amt, flowTime);
		flows.add(newFlow);
	}

	void display(){
		for (int i=0; i<numAddresses; i++){
		    addresses[i].display();
		}

		for (int i=flows.size()-1; i>=0; i--){
		    Flow flow = (Flow) flows.get(i);
		    flow.display();
		    if (flow.isFinished()){
		        flows.remove(i);
		    }
		}
	}


}