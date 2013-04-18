"""
Loads a data file containing a dict mapping from address to address maps
Create a new dict with the following structure:
"addresses": {addr -> addrDict}
"txs": {hash -> txDict}
"blocks": {index -> [tx]}
"positions": [addr]

where
addrDict = parse of blockchain.info json
txDict   = parse of blockchain.info json


"""

import cPickle as pickle
import os, operator

HOMEDIR = "/Users/danmane/Dropbox/Code/Github/Bitcoin-Viz/"
MY_ADDR = "1FEdnu7NYNc6pjaFLvci57aQ6WFbXDJus7"

class BitcoinProcessor:
	def __init__(self, dataFile):
		try:
			with open(dataFile, "r") as f:
				self.data = pickle.load(f)
		except:
			print "Generating new data file"
			self.data = {"addresses": {}, "txs": {}, "blocks": {}, "positions": []}

		self.addresses = self.data["addresses"]
		self.txs       = self.data["txs"]
		self.blocks    = self.data["blocks"]
		self.positions = self.data["positions"]
		self.dataFile  = dataFile

	def load_raw_data(self, rawDataFile):
		try:
			with open(rawDataFile, "r") as f:
				newData = pickle.load(f)
			for addr, addrDict in newData.iteritems():
				self.add_data(addr, addrDict)
		except IOError as e:
			print "IOError: Unable to load", rawDataFile
		self.save_data()

	def save_data(self):
		with open(self.dataFile + "_temp", "w") as f:
			pickle.dump(self.data, f)
		os.rename(self.dataFile + "_temp", self.dataFile)

	def add_data(self, addr, addrDict):
		if addr not in self.addresses or len(addrDict["txs"]) > len(self.addresses[addr]["txs"]):
			# If we have no record on the address, definitely update. If we have a record on the address, update only if it has new (i.e. more) transactions
			self.addresses[addr] = addrDict
			for tx in addrDict["txs"]:
				txHash = tx["hash"]
				if txHash not in self.txs:
					self.txs[txHash] = tx
					try:
						txBlock = tx["block_height"]
						try:
							self.blocks[txBlock].append(tx)
						except KeyError:
							self.blocks[txBlock] = [tx]

					except KeyError:
						print "unable to find block height: ======\n", tx

	def sort_positions(self, starting_addr):
		queue = [starting_addr]
		self.positions = []
		explored = set([starting_addr])
		while queue:
			next = queue.pop(0)
			self.positions.append(next)
			sources = getSources(next)
			for s in sources:
				if s not in explored:
					explored.add(s)
					queue.append(s)
		self.save_data()

	def getSources(addr):
		txs = self.addresses[addr]["txs"]
		sources = []
		for tx in txs:
			inAddrs = []
			ipts = tx["inputs"]
			for i in ipts:
				try:
					inAddrs.append(i["prev_out"]["addr"])
				except KeyError:
					# Newly generated coins have no source
					pass
			if addr not in inAddrs:
				# if addr in inAddrs, then this transaction went from addr to children
				# if addr not in inAddrs, then this transaction went from parents to addr
				sources += inAddrs
		return sources

	def writeInfo(target):
		# placeholder
		print "num addrs:", len(self.addresses)
		sortedblocks = sorted(self.blocks.iteritems(), key=operator.itemgetter(0))
		for (h, b) in sortedblocks:
			print h, ":", len(b)



def main():
	PROCCESSED_DATAFILE = HOMEDIR + "parsed_data.pkl"
	RAW_DATAFILE = HOMEDIR + "rawdata.pkl"

	BP = BitcoinProcessor(PROCCESSED_DATAFILE)
	BP.load_raw_data(RAW_DATAFILE)
	BP.sort_positions(MY_ADDR)
	BP.writeInfo(None)

if __name__ == '__main__':
	main()