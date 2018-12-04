#!/usr/local/bin/python3
# -*- coding: utf-8 -*-
#
#  KonlpyParser.py
#  Sonagi
#
#  Created by chargeflux on 12/2/18.
#  Copyright © 2018 chargeflux. All rights reserved.
#

from konlpy.tag import Okt
import sys
import unicodedata

import argparse

parser = argparse.ArgumentParser(description='Find POS for input (Korean)')
parser.add_argument('--input', type=str, help='Input string for parsing')
parser.add_argument('--type', type=str, help='Specify what to extract')
args = parser.parse_args()

input = args.input
# requires normalization
input = unicodedata.normalize('NFC', input) #NFD doesn't work

okt = Okt()

if args.type == "pos":
    pos = okt.pos(input,norm=True, stem=True,join=True)
    sys.stdout.buffer.write('\n'.join(pos).encode('utf-8'))
