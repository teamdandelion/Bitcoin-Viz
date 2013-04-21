import BitcoinParsers, json

json_tx1 = """{"block_height":232324,"time":1366502060,"inputs":[{}],"vout_sz":1,"relayed_by":"178.63.116.238","hash":"a3e66864b9f0d37441dc30c59b6a44ee31a7d55750e297792549d98e4262f567","vin_sz":1,"tx_index":67268290,"ver":1,"out":[{"n":0,"value":2507080000,"addr":"1JVQw1siukrxGFTZykXFDtcf6SExJVuTVE","tx_index":67268290,"type":0}],"size":144}"""
json_tx2 = """{"block_height":228290,"time":1364399266,"inputs":[{"prev_out":{"n":1,"value":6206486000,"addr":"1N88NAZ8Mbu3ZWXfkGkmVYGBabnRFiJ5kR","tx_index":63166726,"type":0}}],"vout_sz":2,"relayed_by":"69.195.155.226","hash":"2ccc803bd7252e54f348db36e08d9d6ff25edfa4358d516bda33cae8df754433","vin_sz":1,"tx_index":63172626,"ver":1,"out":[{"n":0,"value":5642260000,"addr":"1Ng5eg7V3dSKMBFDu5hmhTsEzjfPND8Vms","tx_index":63172626,"type":0},{"n":1,"value":564226000,"addr":"1JF1aQjQtGnWCZajpp4gxcLBrKHdmTzgB8","tx_index":63172626,"type":0}],"size":226}"""
json_tx3 = """{"block_height":228261,"time":1364397847,"inputs":[{"prev_out":{"n":0,"value":18350002,"addr":"1NJrs7mFwmnMMHKC8EEqo3mL9pwzwgiiHp","tx_index":62803612,"type":0}},{"prev_out":{"n":1,"value":450000000,"addr":"1F2ZwRXUry9r48FN5L9vBveQraURYArvZf","tx_index":62313881,"type":0}},{"prev_out":{"n":0,"value":4597242597,"addr":"1Aa9FFaCKMAqWAGFXqt2jrqS53zeHJkDFW","tx_index":62286951,"type":0}},{"prev_out":{"n":1,"value":4231237593,"addr":"12kk3unegcY1iyKir3LrFfhuAdyRQgj54i","tx_index":62530080,"type":0}}],"vout_sz":2,"relayed_by":"79.114.169.251","hash":"a5bbeabc200bc9892a724ed65e4ed3ba94e45cb411a4eff040d4b663888acf34","vin_sz":4,"tx_index":63166726,"ver":1,"out":[{"n":0,"value":3090294192,"addr":"1Di7TWGx25WN1dN3oBQaUrVRmkPR8cNk7h","tx_index":63166726,"type":0},{"n":1,"value":6206486000,"addr":"1N88NAZ8Mbu3ZWXfkGkmVYGBabnRFiJ5kR","tx_index":63166726,"type":0}],"size":800}"""

raw_tx1 = json.loads(json_tx1)
raw_tx2 = json.loads(json_tx2)
raw_tx3 = json.loads(json_tx3)

parse_tx1 = {"hash": u"a3e66864b9f0d37441dc30c59b6a44ee31a7d55750e297792549d98e4262f567",
	"block_height": 232324											     ,
	"inputs"      : []												     ,
	"outputs"     : [(u"1JVQw1siukrxGFTZykXFDtcf6SExJVuTVE", 2507080000)],
	"total_in"    : 0												     ,
	"total_out"   : 2507080000										     }

def testTxParser():
	actual = BitcoinParsers.parse_txdict(raw_tx1)
	assertEquals(parse_tx1, actual, "testTxParser")

def main():
	testTxParser()

def assertEquals(expected, actual, msg = ""):
	try:
		assert expected == actual
		if msg != "":
			print msg + " passed!"
			
	except AssertionError:
		print msg + " failed!"
		print "Expected:"
		print expected
		print "Actual:"
		print actual



if __name__ == '__main__':
	main()

