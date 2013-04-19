

def parse_addrdict(rawDict):
	return {"n_tx"		: rawDict["n_tx"]						   , 
			"total_in"	: rawDict["total_received"]				   ,
			"total_out"	: rawDict["total_sent"]					   , 
			"final_bal"	: rawDict["final_balance"]				   ,
			"txs"       : [parse_txdict(d) for d in rawDict["txs"]]}

def parse_txdict(rawDict):
	txdict    = {"hash": rawDict["hash"]}
	inputs    = []
	outputs   = []
	total_in  = 0
	total_out = 0

	try:
		txdict["block_height"] = rawDict["block_height"]
	except KeyError:
		txdict["block_height"] = None
	
	for i in rawDict["inputs"]:
		# TODO: Need to handle generation transactions
		try:
			p = i["prev_out"]
			total_in += p["value"]
			inputs.append(  (p["addr"], p["value"])  )

		except KeyError:
			raise NotImplementedError

	for o in rawDict["out"]:
		total_out += o["value"]
		outputs.append( (o["addr"], o["value"]))

	if total_in != total_out:
		print "WARNING: Transaction in not equal transaction out!"
		print rawDict

	txdict["total"]   = total_in
	txdict["inputs"]  = inputs
	txdict["outputs"] = outputs
	return txdict
