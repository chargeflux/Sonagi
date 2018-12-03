from konlpy.tag import Okt
import sys
import unicodedata

import argparse

parser = argparse.ArgumentParser(description='Find POS for input (Korean)')
parser.add_argument('--input', type=str, help='Input string for parsing')
args = parser.parse_args()

input = args.input
# requires normalization
input = unicodedata.normalize('NFC', input) #NFD doesn't work

okt = Okt()

pos = okt.pos(input,norm=True, stem=True,join=True)

sys.stdout.buffer.write('\n'.join(pos).encode('utf-8'))