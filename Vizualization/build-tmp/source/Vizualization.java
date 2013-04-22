import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Vizualization extends PApplet {

Manager myManager;
XML myXML;

int XBOUND = 800;
int YBOUND = 800;
int RADIUS = 360;
int N_CIRCLES = 800;
// The spiral code taken from a Processing.js example by 
// Jim Bumgardner
// http://krazydad.com/tutorials/circles_js/showexample.php?ex=phyllo_equal

float PHI = (sqrt(5) + 1)/2 -1;
float GOLDEN_ANGLE = PHI * TWO_PI;
float LG_AREA = sq(RADIUS) * PI;
float SM_AREA = LG_AREA / N_CIRCLES;
float SM_RAD  = sqrt(SM_AREA / PI) * 2 * 0.87f;
float CX = XBOUND / 2.0f;
float CY = YBOUND / 2.0f;



XYCoord CENTERPOINT = new XYCoord(CX, CY);


public void setup(){
    println("Starting setup");
    size(XBOUND, YBOUND);
    noStroke();
    println("Loading XML");
    myXML = loadXML("transactions.xml");
    //println(myXML);
    println("Got XML; starting manager init");
    myManager = new Manager(myXML);

};

public void draw(){
    translate(20,20);
    background(155);
    myManager.display();

};


public XYCoord position2XY(int position){
    int pos = position + 1;
    float angle = pos * GOLDEN_ANGLE;
    float cum_area = pos * SM_AREA;
    float spiral_rad = sqrt(cum_area / PI);
    float x = CX + cos(angle) * spiral_rad;
    float y = CY + sin(angle) * spiral_rad;

    return new XYCoord(x, y);
}

public int size2color(int bitcoins){
    return color(0,0,0);
}

public float size2radius(int bitcoins){
    return sqrt(bitcoins) / 3;
}

public void drawCircle(XYCoord xy, float radius, int c){
    fill(c);
    ellipse(xy.getX(), xy.getY(), radius*2, radius*2);


}

class Address {
    int currentBitcoins;
    int position;
    XYCoord loc;

    Address(int pos){
        position = pos;
        currentBitcoins = 0;
        loc = position2XY(position);
    }

    public XYCoord getXY(){
        return loc;
    }

    public int addBitcoins(int amt){
        return currentBitcoins += amt;
    }

    public int subtractBitcoins(int amt){
        currentBitcoins -= amt;
        if (currentBitcoins < 0){
            println("Warning: Addr:" + position + " has amt: " + currentBitcoins);
        }
        return currentBitcoins;

    }

    public void display(){
        int c = size2color(currentBitcoins);
        float radius = size2radius(currentBitcoins);
        drawCircle(loc, radius, c);
    }

    public void forceDisplay(){
        int c = color(0,0,0);
        float radius = 20;
        drawCircle(loc, radius, c);

    }
};

class Block{
    Transaction[] txs;
    int numTransactions;
    Manager myManager;
    int blockNum;
    
    Block(Manager myManager, XML blockXML){
        this.myManager = myManager;

        XML[] transactionXMLs = blockXML.getChildren("Transaction");
        numTransactions = blockXML.getInt("Transactions");
        blockNum = blockXML.getInt("Number");

        txs = new Transaction[numTransactions];
        for (int i=0; i<numTransactions; i++){
            txs[i] = new Transaction(transactionXMLs[i]);
        }
    }

    public void addFlows(){
        println("Adding block: " + blockNum);
        for (int i=0; i<numTransactions; i++){
            txs[i].addFlows(myManager);
        }
    }

};

class Transaction{
    int   numInputs     , numOutputs     ;
    int[] inputPositions, outputPositions;
    int[] inputAmounts  , outputAmounts  ;
    int totalOut;
    boolean isGenerative;

    Transaction(XML transactionXML){
        XML inputs, outputs;

        String genStr = transactionXML.getString("Generative");
        if (genStr.equals("True")){
            isGenerative = true;
        } else if (genStr.equals("False")){
            isGenerative = false;
        } else {
            println("|" + genStr + "|");
            assert false;
        }

        inputs  = transactionXML.getChild("Inputs");
        outputs = transactionXML.getChild("Outputs");

        numInputs  = inputs.getInt("Num");
        numOutputs = outputs.getInt("Num");
        totalOut   = outputs.getInt("Total");

        XML[] inFlows  = inputs.getChildren("Flow");
        XML[] outFlows = outputs.getChildren("Flow");

        inputPositions = new int[numInputs];
        inputAmounts   = new int[numInputs];

        outputPositions = new int[numOutputs];
        outputAmounts   = new int[numOutputs];

        for (int i=0; i<numInputs; i++){
            XML flow = inFlows[i];
            int pos = flow.getInt("Position");
            int amt = flow.getInt("Amt");
            inputPositions[i] = pos;
            inputAmounts[i]   = amt;
        }

        for (int i=0; i<numOutputs; i++){
            XML flow = outFlows[i];
            int pos = flow.getInt("Position");
            int amt = flow.getInt("Amt");
            outputPositions[i] = pos;
            outputAmounts[i]   = amt;
        }
    }


    public void addFlows(Manager myManager){
        if (isGenerative){
            int outPos, outAmt;
            // I think generative trx have only one output
            // But let's iterate over the list to be safe
            for (int i=0; i<numOutputs; i++){
                outPos = outputPositions[i];
                outAmt = outputAmounts[i];
                myManager.addBitcoins(outPos, outAmt);
            }
        } else {
            addNormalFlows(myManager);
        }
    }

    public void addNormalFlows(Manager myManager){
        // Issue: Due to rounding issues, this algorithm
        // May lose track of a few ubitcoins when transactions have 
        // Multiple outputs
        int amt, outAmt;
        int srcPos, dstPos;
        float p;

        for (int i=0; i<numInputs; i++){
            amt = inputAmounts[i];
            srcPos = inputPositions[i];
            for (int j=0; j<numOutputs; j++){
                p = (float) outputAmounts[j] / totalOut;
                outAmt = (int) (amt * p);
                dstPos = outputPositions[j];

                myManager.addFlow(srcPos, dstPos, outAmt);
            }
        }
    }


};

class Flow {
    Address destination;
    XYCoord sourceXY, destinationXY;
    int amount;
    int travelTime;  // in miliseconds
    int startTime; // in miliseconds
    boolean finished;
    int myColor;

    Flow(Address source, Address destination, int amount, int travelTime){
        this.destination = destination;
        this.amount = amount;
        this.travelTime = travelTime;
        startTime = millis();
        
        assert (source != null || destination != null);

        if (source == null){
            destinationXY = destination.getXY();
            sourceXY = destinationXY.getRadialXY();
            myColor = color(255,0,0); // OON->IN = Red
        } else if (destination == null){
            sourceXY = source.getXY();
            destinationXY = sourceXY.getRadialXY();
            myColor = color(0,255,0); // IN->OUT = Green
        } else {
            sourceXY = source.getXY();
            destinationXY = destination.getXY();
            myColor = color(255,255,255); // IN->IN = Black
        }

        if (source != null){
            source.subtractBitcoins(amount);
        }
        finished = false;
    }

    public void display(int currentTime){
        if (!finished){
            if (currentTime > travelTime + startTime){
                // Flow is finished
                if (destination != null){
                    destination.addBitcoins(amount);
                }

                finished = true;
            } else {
                drawFlow(currentTime);
            }
        }
    }

    public boolean isFinished(){
        return finished;
    }

    public void drawFlow(int currentTime){
        float p = (float) (currentTime - startTime) / travelTime;
        XYCoord myLocation = sourceXY.travelAlong(destinationXY, p);
        int c = myColor;
        float radius = size2radius(amount);
        drawCircle(myLocation, radius, c);
    }

};

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
		numAddrs  = bitcoinXML.getInt("NumAddrs");
		print("Num addrs is: " + numAddrs);

		addrs  = new Address[numAddrs];
		for (int i=0; i<numAddrs; i++){
		    addrs[i] = new Address(i);
		}

		println("Allocated addrs");

		numBlocks = bitcoinXML.getInt("NumBlocks");
		println("Got NumBlocks: " + numBlocks);

		blockXMLs = bitcoinXML.getChildren("Block");
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

	public void addBlock(){
		if (currentBlockIndex<numBlocks){
			blocks[currentBlockIndex].addFlows();
			currentBlockIndex++;			
		}

	}

	public void addBitcoins(int pos, int amt){
		if (pos != -1){
			addrs[pos].addBitcoins(amt);
		}
	}

	public void addFlow(int srcPos, int dstPos, int amt){
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

	public void display(){
		int currentTime = millis();
		if ((currentTime - startTime) / flowTime > currentBlockIndex){
			addBlock();
		}

		for (int i=0; i<numAddrs; i++){
		    addrs[i].display();
		}

		for (int i=flows.size()-1; i>=0; i--){
		    Flow flow = (Flow) flows.get(i);
		    flow.display(currentTime);
		    if (flow.isFinished()){
		        flows.remove(i);
		    }
		}
	}


};

class XYCoord{
    float x, y;
    
    XYCoord(float x, float y){
        this.x = x;
        this.y = y;
    }

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

    public XYCoord add(XYCoord otherCoord){
        return new XYCoord(x + otherCoord.getX(), y + otherCoord.getY());
    }

    public XYCoord subtract(XYCoord otherCoord){
        return new XYCoord(x - otherCoord.getX(), y - otherCoord.getY());
    }

    public XYCoord multiply(float scalar){
        return new XYCoord(x * scalar, y * scalar);
    }

    public XYCoord divide(float scalar){
        return new XYCoord(x / scalar, y / scalar);
    }

    public XYCoord travelAlong(XYCoord destination, float proportion){
        XYCoord diffVector;
        diffVector = destination.subtract(this).multiply(proportion);
        return this.add(diffVector);
    }

    public float getLength(){
        return sqrt(x*x + y*y);
    }

    public XYCoord getUnitVector(){
        return this.divide(this.getLength());
    }

    public XYCoord getRadialXY(){
        XYCoord uv = this.getUnitVector();
        return uv.multiply(RADIUS+100).add(CENTERPOINT);
    }

};
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Vizualization" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
