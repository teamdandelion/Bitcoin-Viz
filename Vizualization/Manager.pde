import java.util.Arrays;

class Manager{
	int numAddrs;
	int numBlocks;
	Address[] addrs;
	ArrayList flows;
	Block[] blocks;
	XML[] blockXMLs;
	int flowTime = 500;
	int currentBlockIndex = 0;
	int startTime;



	Manager(XML bitcoinXML){
		XML addrElem = bitcoinXML.getChild("Addrs");
		XML blockElem = bitcoinXML.getChild("Blocks");
		numAddrs  = addrElem.getInt("NumAddrs");
		println("Num addrs is: " + numAddrs);

		XML[] addrXMLs = addrElem.getChildren("Addr");
		println("Got addr children");

		addrs  = new Address[numAddrs];
		for (int i=0; i<numAddrs; i++){
			XML a = addrXMLs[i];
			assert (a.getInt("Position") == i);
			int sbal = a.getInt("StartingBalance");
		    addrs[i] = new Address(i);
		    addrs[i].addBitcoins(sbal);
		}

		println("Allocated addrs");

		numBlocks = blockElem.getInt("NumBlocks");
		println("Got NumBlocks: " + numBlocks);

		blockXMLs = blockElem.getChildren("Block");
		println("Got blockXMLs, len:" + blockXMLs.length);

		blocks = new Block[numBlocks];
		for (int i=0; i<numBlocks; i++){
			println("i=" + i);
			blocks[i] = new Block(this, blockXMLs[i]);
		}

		println("Allocated blocks");

		flows  = new ArrayList();	

		println("Finished manager setup");
		startTime = millis();
	}

	void addBlock(){
		if (currentBlockIndex<numBlocks){
			blocks[currentBlockIndex].addFlows();
			currentBlockIndex++;			
		}

	}

	void addBitcoins(int pos, int amt){
		if (pos != -1){
			addrs[pos].addBitcoins(amt);
		}
	}

	void addFlow(int srcPos, int dstPos, int amt){
		Address srcAddr, dstAddr;
		if (srcPos == -1 && dstPos == -1){
			return; // No need to add the flow, its between
			// out of network 
		}

		if (srcPos == dstPos){
			println("Got a flow from " + srcPos + " to self, amt:" + amt);
			return;
		}

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
		int currentTime = millis();
		if ((currentTime - startTime) / flowTime > currentBlockIndex){
			addBlock();
		}

		Arrays.sort(addrs);
		for (int i=0; i<numAddrs; i++){
		    addrs[i].display();
		    print(addrs[i].getBalance() + ",");
		}
		println();

		for (int i=flows.size()-1; i>=0; i--){
		    Flow flow = (Flow) flows.get(i);
		    flow.display(currentTime);
		    if (flow.isFinished()){
		        flows.remove(i);
		    }
		}
	}
};

