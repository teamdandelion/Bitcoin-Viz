
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

    void addFlows(){
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


    void addFlows(Manager myManager){
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

    void addNormalFlows(Manager myManager){
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
