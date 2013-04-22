

def parse_addrdict(rawDict):
	parsed = {"n_tx"		: rawDict["n_tx"]						   , 
			 "total_in"		: rawDict["total_received"]				   ,
			 "total_out"	: rawDict["total_sent"]					   , 
			 "final_bal"	: rawDict["final_balance"]				   ,
			 "txs"       	: [parse_txdict(d) for d in rawDict["txs"]]}

	visible_in  = 0
	visible_out = 0
	# for tx in parsed["txs"]:

	return parsed

def parse_txdict(rawDict):
	txdict    = {"hash": rawDict["hash"], "generative": False}
	inputs    = []
	outputs   = []
	total_in  = 0
	total_out = 0

	try:
		txdict["block_height"] = rawDict["block_height"]
	except KeyError:
		txdict["block_height"] = None
	
	for i in rawDict["inputs"]:
		try:
			p = i["prev_out"]
			total_in += p["value"]
			inputs.append(  (p["addr"], p["value"])  )

		except KeyError:
			txdict["generative"] = True

	for o in rawDict["out"]:
		try:
			outputs.append( (o["addr"], o["value"]))
			total_out += o["value"]
		except KeyError:
			pass # some transactions are just weird...

	txdict["total_in"]  = total_in
	txdict["total_out"] = total_out
	txdict["inputs"]    = inputs
	txdict["outputs"]   = outputs
	return txdict
