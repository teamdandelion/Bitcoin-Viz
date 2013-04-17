"""
Seeks out bitcoin history by querying blockchain.info json API. Does a BFS over
the transaction history to find the history of the bitcoins. Can search either to
specified recursion depth or specificed number of addresses.
"""
import cPickle as pickle
import datetime, json, urllib2, os, time

VERBOSE = True
DLS_TO_SAVE   = 10 # how often do we back up our data file 
REQUEST_TIMER = 5  # how long to wait between sending api requests
LAST_REQUEST = 0
HOMEDIR = "/Users/danmane/Dropbox/Code/Github/Bitcoin-Viz"

# ============================================================================ #

class BitcoinDownloader:
	def __init__(self, dataFile):
		self.dataFile = dataFile

		self.loadData()
		self.nDownloads = 0

	# String -> AddressDictionary
	def getAddr(self, addr):
		if addr not in self.addrMap:
			
			newAddr = downloadAddr(addr)
			self.addrMap[addr] = newAddr
			self.addrList.append(newAddr)
			self.nDownloads += 1

			if self.nDownloads % DLS_TO_SAVE is 0:
				self.saveData()

		return self.addrMap[addr]

	def BFS(self, addr, maxx, depthMode=False):
		# If Depthmode: Max is taken as the max depth to explore
		# If not Depthmode: Max is taken as the number of nodes to explore
		parseQueue = [(addr, 0)] # (Addr, Depth)
		count = 0
		if VERBOSE: print "Beginning BFS, max = ", maxx, " depthMode = ", depthMode

		while parseQueue: # Tests emptiness
			(nextAddr, depth) = parseQueue.pop(0) 
			if VERBOSE: print "Processing ", nextAddr
			count += 1
			sources = self.getSources(nextAddr) # Minor optimization possibility here
			if depthMode and depth < maxx:
				for s in sources:
					parseQueue.append( (s, depth+1) )
			elif (not depthMode):
				while sources and count < maxx:
					s = sources.pop(0)
					parseQueue.append( (s, depth+1) )

		self.saveData()
		print "Finished breadth first search: found ", count, " nodes, final depth of \
		", depth
		return True

	def saveData(self):
		with open(self.dataFile + "_temp", "w") as f:
			data = self.addrMap, self.addrList
			pickle.dump(data, f)

		# Use an atomic rename to avoid corruption if program crashes during write
		os.rename(self.dataFile + "_temp", self.dataFile) 

		return True

	def getSources(self, addr):
		data = self.getAddr(addr)
		txs = data["txs"]
		sources = []
		for tx in txs:
			inAddrs = []
			ipts = tx["inputs"]
			for i in ipts:
				inAddrs.append(i["prev_out"]["addr"])
			if addr not in inAddrs:
				# if addr in inAddrs, then this transaction went from addr to children
				# if addr not in inAddrs, then this transaction went from parents to addr
				sources += inAddrs
		return sources

	def loadData(self):
		try:
			with open(self.dataFile, "r") as f:
				self.addrMap, self.addrList = pickle.load(f)
		except:
			self.addrMap  = {} # A dict of AddrStr -> AddrProperties 
			self.addrList = [] # A list of Addrs in the parse order

		self.nAddrs = len(self.addrList)

		return True

# ============================================================================ #

def downloadAddr(addr):
	global LAST_REQUEST
	timeDelta = time.time() - LAST_REQUEST
	if timeDelta < REQUEST_TIMER:
		sleepTime = REQUEST_TIMER - timeDelta
		if VERBOSE: print "\t\tSleeping for ", sleepTime, " seconds"
		time.sleep(sleepTime)

	LAST_REQUEST = time.time()

	url = "http://blockchain.info/rawaddr/" + addr
	jsonStr = urllib2.urlopen(url).read()
	data = json.loads(jsonStr)

	return data

def testDownloader():

	testFile = HOMEDIR + "/testData.pkl"
	with open(testFile, "w") as f:
		pass # overwrites the file

	testBD = BitcoinDownloader(HOMEDIR + "/testData.pkl")
	testAddr = "1N88NAZ8Mbu3ZWXfkGkmVYGBabnRFiJ5kR"
	testBD.BFS(testAddr, 1, True)
	assert testBD.nDownloads == 5
	addrs = [testAddr, 
			"1NJrs7mFwmnMMHKC8EEqo3mL9pwzwgiiHp", 
			"1F2ZwRXUry9r48FN5L9vBveQraURYArvZf",
			"1Aa9FFaCKMAqWAGFXqt2jrqS53zeHJkDFW",
			"12kk3unegcY1iyKir3LrFfhuAdyRQgj54i"]
	for a in addrs:
		assert a in testBD.addrMap

	print "Tests passed!"
	os.remove(testFile)
	return True

def main():
	MY_ADDR = "1FEdnu7NYNc6pjaFLvci57aQ6WFbXDJus7"
	DATAFILE = HOMEDIR + "/rawdata.pkl"
	bd = BitcoinDownloader(DATAFILE)
	bd.BFS(MY_ADDR, 50, False)

if __name__ == '__main__':
	main()