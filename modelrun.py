#!/usr/bin/env python3

import sys
import os

from profilingmodelpy import model

import re

# parse existing results to pass into the model

txtfile = sys.argv[1]
print(f"Parsing {txtfile}...")

cpu_proto_t_sub_i = -1
cpu_sha3_t_sub_i = -1
cpu_other_t_sub_i = -1
accel_proto_t_sub_i = -1
accel_sha3_t_sub_i = -1
accel_proto_t_setup_i = -1
accel_sha3_t_setup_i = -1

with open(txtfile) as f:
    for l in f:
        m = re.match(r"^.*CPU Protobuf.*t_sub_i.*= (.*)", l)
        if m:
            cpu_proto_t_sub_i = float(m.group(1))

        m = re.match(r"^.*CPU SHA3.*t_sub_i.*= (.*)", l)
        if m:
            cpu_sha3_t_sub_i = float(m.group(1))

        m = re.match(r"^.*CPU Other.*t_sub_i.*= (.*)", l)
        if m:
            cpu_other_t_sub_i = float(m.group(1))

        m = re.match(r"^.*Accel. Protobuf.*t_sub_i.*= (.*)", l)
        if m:
            accel_proto_t_sub_i = float(m.group(1))

        m = re.match(r"^.*Accel. SHA3.*t_sub_i.*= (.*)", l)
        if m:
            accel_sha3_t_sub_i = float(m.group(1))

        m = re.match(r"^.*Accel. Protobuf.*t_setup_i.*= (.*)", l)
        if m:
            accel_proto_t_setup_i = float(m.group(1))

        m = re.match(r"^.*Accel. SHA3.*t_setup_i.*= (.*)", l)
        if m:
            accel_sha3_t_setup_i = float(m.group(1))

assert (cpu_proto_t_sub_i != -1 and 
	cpu_sha3_t_sub_i != -1 and 
	cpu_other_t_sub_i != -1 and 
	accel_proto_t_sub_i != -1 and 
	accel_sha3_t_sub_i != -1 and
	accel_proto_t_setup_i != -1 and 
	accel_sha3_t_setup_i != -1), f"Something went wrong. Check {txtfile}"

# run the model

chained_cpu_components_ordered = ["proto", "sha3"]
unchained_cpu_components = {"other"}
all_cpu_components = unchained_cpu_components | set(chained_cpu_components_ordered)

debug = True
printbottleneck = False
ignore_t_dep = True
f = 1

t_sub_i = {
	"proto": cpu_proto_t_sub_i,
	"sha3": cpu_sha3_t_sub_i,
	"other": cpu_other_t_sub_i,
}

# convert to pcts
pcts_i = {}
t_e2e = sum(t_sub_i.values())
for k, v in t_sub_i.items():
	pcts_i[k] = 100 * v / t_e2e

s_sub_i = {
	"proto" : cpu_proto_t_sub_i/accel_proto_t_sub_i,
	"sha3" : cpu_sha3_t_sub_i/accel_sha3_t_sub_i,
	"other" : 1,
}

t_setup_i = {
	"proto" : accel_proto_t_setup_i,
	"sha3" : accel_sha3_t_setup_i,
	"other" : 0,
}

# offchip accesses
oo_i = {
	"proto" : False,
	"sha3" : False,
	"other" : False,
}

# bytes offchip
b_i = {
	"proto" : 0,
	"sha3" : 0,
	"other" : 0,
}

# misc. factors
ones_i = {
	"proto" : 1,
	"sha3" : 1,
	"other" : 1,
}

t_prime_e2e = model.t_prime_end2end(
	t_e2e,
	0,
	t_e2e,
	pcts_i,
	ones_i,
	t_setup_i,
	s_sub_i,
	oo_i,
	b_i, # unused
	0, # unused
	all_cpu_components,
	unchained_cpu_components,
	chained_cpu_components_ordered,
	debug,
	printbottleneck,
	ignore_t_dep,
	pct_t_dep=-1, # unused
)

print("Success")
