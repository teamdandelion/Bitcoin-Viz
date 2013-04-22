class Manager{
	int numAddrs;
	Address[] addrs;
	ArrayList flows;
	Block[] blocks;
	int flowTime = 3000;
	int currentBlockIndex = 0;


	Manager(XML bitcoinXML){
		addrs = new Address[numAddrs];
		flows = new ArrayList();
		for (int i=0; i<numAddrs; i++){
		    addrs[i] = new Address(i);
		}

		//TODO: Add the blocks!
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
		// need to handle -1 case
		Flow newFlow = new Flow(addrs[srcPos], addrs[dstPos], amt, flowTime);
		flows.add(newFlow);
	}

	void addFlow(int dstPos, int amt){
		Flow newFlow = new Flow(addrs[dstPos], amt, flowTime);
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