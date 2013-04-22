

def parse_addrdict(addr, rawDict):
	parsed = {"n_tx"		: rawDict["n_tx"]						   , 
			 "total_in"		: rawDict["total_received"]				   ,
			 "total_out"	: rawDict["total_sent"]					   , 
			 "final_bal"	: rawDict["final_balance"]				   ,
			 "txs"       	: [parse_txdict(d) for d in rawDict["txs"]]}

	visible_in  = 0
	visible_out = 0
	for tx in parsed["txs"]:
		ipts = tx["inputs"]
		opts = tx["outputs"]
		if addr in ipts:
			visible_out += ipts[addr]
		if addr in opts:
			visible_in += opts[addr]
		# This may look backwards, but makes sense
		# If the addr is listed as an input to the transaction, then its coming out of the addr
		# If the addr is listed as an output for the transaction, its coming into the addr

	# final = in - out + starting
	# starting = final + out - in
	starting_bal = rawDict["final_balance"] + visible_out - visible_in
	parsed["starting_bal"] = starting_bal

	return parsed

def parse_txdict(rawDict):
	txdict    = {"hash": rawDict["hash"], "generative": False}
	inputs    = {}
	outputs   = {}
	total_in  = 0
	total_out = 0

	try:
		txdict["block_height"] = rawDict["block_height"]
	except KeyError:
		txdict["block_height"] = None
	
	for i in rawDict["inputs"]:
		try:
			p = i["prev_out"]
			addr = p["addr"]
			amt  = p["value"]
			total_in += amt
			if addr not in inputs:
				inputs[addr] = amt
			else:
				inputs[addr] += amt

		except KeyError:
			txdict["generative"] = True

	for o in rawDict["out"]:
		try:
			addr = o["addr"]
			amt  = o["value"]

			total_out += amt

			if addr not in outputs:
				outputs[addr] = amt
			else:
				outputs[addr] += amt
		except KeyError:
			pass # some transactions are just weird...

	txdict["total_in"]  = total_in
	txdict["total_out"] = total_out
	txdict["inputs"]    = inputs
	txdict["outputs"]   = outputs
	return txdict
