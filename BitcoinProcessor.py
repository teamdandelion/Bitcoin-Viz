"""
Loads a data file containing a dict mapping from address to address maps
Create a new dict with the following structure:
"addresses": {addr -> addrDict}
"txs": {hash -> tx_dict}
"blocks": {index -> [tx]}
"positions": [addr]

where
addrDict = parse of blockchain.info json
tx_dict   = parse of blockchain.info json

tx_dict=
	"inputs"       -> [(Addr, Amt)]
	"outputs"      -> [(Addr, Amt)]
	"block_height" -> Int OR None (when unconfirmed)
	"total"		   -> Amt

addrDict =
	"txs"          -> [tx_dict] # sorted by block height
	"n_tx"         -> Number of transactions
	"total_in"	   -> Amt
	"total_out"    -> Amt
	"final_bal"    -> Amt

"""

import cPickle as pickle
import os, operator, BitcoinParsers
from lxml import etree

HOMEDIR = "/Users/danmane/Dropbox/Code/Github/Bitcoin-Viz/Data/"
MY_ADDR = "1FEdnu7NYNc6pjaFLvci57aQ6WFbXDJus7"


class BitcoinProcessor:
	def __init__(self, rawFile, dataFile=None):
		try:
			with open(dataFile, "r") as f:
				self.data = pickle.load(f)
			print "Loaded data from file"
			need_to_load = False
		except:
			print "Generating new data file"
			self.data = {"addresses": {}}
			need_to_load = True

		self.addrs     = self.data["addresses"]
		# self.txs       = self.data["txs"]
		# self.blocks    = self.data["blocks"]
		# self.positions = self.data["positions"]
		self.dataFile  = dataFile
		if need_to_load:
			self.load_raw_data(rawFile)

	def load_raw_data(self, rawDataFile):
		try:
			with open(rawDataFile, "r") as f:
				newData = pickle.load(f)
			for addr, rawAddrDict in newData.iteritems():
				self.add_data(addr, rawAddrDict)
		except IOError as e:
			print "IOError: Unable to load", rawDataFile
		self.save_data()

	def save_data(self):
		try:
			with open(self.dataFile + "_temp", "w") as f:
				pickle.dump(self.data, f)
			os.rename(self.dataFile + "_temp", self.dataFile)
			print "Saved data successfully"
		except:
			print "Warning: Unable to save data file"

	def add_data(self, addr, rawAddrDict):
		if addr not in self.addrs or rawAddrDict["n_tx"] > self.addrs[addr]["n_tx"]:
			# If we have no record on the address, definitely update. 
			# If we have a record on the address, update only if it has 
			# new (i.e. more) transactions
			# Just note, we're comparing rawAddrDict["n_tx"] to addrDict["n_tx"]
			# Ie. comparing raw JSON data to our formatted dict. Shouldn't matter.
			addrDict = BitcoinParsers.parse_addrdict(rawAddrDict)
			self.addrs[addr] = addrDict
			for tx in addrDict["txs"]:
				txHash = tx["hash"]
				self.txs[txHash] = tx # Overwrite if already exists
				txBlock = tx["block_height"]
				if txBlock is not None:
					try:
						self.blocks[txBlock].append(tx)
					except KeyError:
						self.blocks[txBlock] = [tx]

	def build_blocks(self):
		self.blocks = {}
		for addr in self.addr2position.iterkeys():


	def sort_positions(self, starting_addr, targetDepth):
		# Does a BFS over the transaciton history starting with starting_addr
		# Returns positions, a list of addresses in the order they are discovered
		# (naturally this starts with starting_addr)
		# Also returns addr2position, a map from an address to its position in this list
		# The purpose of this section is that, for simplicity, i want to abstract away from 
		# addresses for the XML that I will import into processing. Ie. we refer 
		# to the starting address consistently as 0, its immediate sources as 1,2,3..
		# -1 means out-of-observed-network
		print "Sorting positions with depth", targetDepth
		queue = [(starting_addr, 0)]
		positions = []
		explored = set([starting_addr])
		while queue:
			next, depth = queue.pop(0)
			positions.append(next)
			if depth < targetDepth:
				sources = self.getSources(next)
				for s in sources:
					if s in self.addrs and s not in explored:
						explored.add(s)
						queue.append((s, depth+1))

		addr2position = {}
		for i in xrange(len(positions)):
			a = positions[i]
			addr2position[a] = i

		self.positions = positions
		self.addr2position = addr2position

	def getSources(self, addr):
		txs = self.addrs[addr]["txs"] # May throw key error - need to account for situation where sources are not in scope
		sources = []
		for tx in txs:
			ipts = tx["inputs"]
			inAddrs = [i[0] for i in tx["inputs"]]
			if addr not in inAddrs:
				# if addr in inAddrs, then this transaction went from addr to children
				# if addr not in inAddrs, then this transaction went from parents to addr
				sources += inAddrs
		return sources

	def write_xml(self, starting_addr, filename, depth=3):
		# Write an xml file (see template.xml) which contains all the info on transactions
		# For processing to parse and make art
		self.sort_positions(starting_addr, depth)
		# Sorted blocks is a list of (Blocknumber, Block) tuples sorted by blocknumber
		sortedblocks = sorted(self.blocks.iteritems(), key=operator.itemgetter(0))

		root = etree.Element("BitcoinXML")

		self.txID = 0 # Transaction ID is globally unique for the xml, i.e. not block specific

		for bnum, block in sortedblocks:
			self.write_block(root, bnum, block)

		with open(filename, "w") as f:
			xmlstr = etree.tostring(root, pretty_print=True)
			f.write(xmlstr)


	# parent 	:: XML Element
	# blockNum  :: Int
	# Block 	:: [Transaction]
	# Transaction :: {} String hash, 
	#				 Bool generative, 
	#				 Int total_in, total_out, 
	#				 [flow], [flow]
	# Flow :: (String Addr, Int Amount)

	def write_block(self, parent, blockNum, block):
		relevant_trx = getRelevant(block)

		block_elem = etree.SubElement(parent, "Block", \
						Number=str(blockNum), Transactions=str(len(block)))
		for tx_dict in block:
			# Each transaction has a unique (sequential, increasing) ID
			tx_elem = etree.SubElement(block_elem, "Transaction", \
						ID=str(self.txID), Generative=str(tx_dict["generative"]))
			self.txID += 1

			num_inputs  = str(len(tx_dict["inputs" ]))
			num_outputs = str(len(tx_dict["outputs"]))

			total_in  = str(tx_dict["total_in" ])
			total_out = str(tx_dict["total_out"])

			in_elem = etree.SubElement(tx_elem, "Inputs", \
						Num=num_inputs, Total=total_in)
			
			out_elem = etree.SubElement(tx_elem, "Outputs", \
						Num=num_outputs, Total=total_out)

			for flow in tx_dict["inputs"]:
				self.write_flow(in_elem, flow)

			for flow in tx_dict["outputs"]:
				self.write_flow(out_elem, flow)

	def getRelevant(self, block):
		# Takes a list of transactions (i.e. a block) and returns those transactions that 
		# involve addresses included in self.addr2position
		# i.e. transactions where at least 1 node is in our network
		for tx in block:
			if 

	def write_flow(self, parent, (addr, amount)):
		try:	
			position = self.addr2position[addr]
		except KeyError:
			assert 0
			position = -1
			# -1 signifies out-of-network

		flowE = etree.SubElement(parent, "Flow", Position=position, Amt=amount)
		# posE = etree.SubElement(flowE, "Position")
		# posE.text = str(position)

		# amtE = etree.SubElement(flowE, "Amt")
		# amtE.text = str(amount)






def main():
	PROCCESSED_DATAFILE = HOMEDIR + "parsed_data.pkl"
	RAW_DATAFILE = HOMEDIR + "rawdata.pkl"
	XMLFILE = HOMEDIR + "transactions.xml"

	BP = BitcoinProcessor(RAW_DATAFILE, PROCCESSED_DATAFILE)
	
	BP.write_xml(MY_ADDR, XMLFILE, 3)

if __name__ == '__main__':
	main()