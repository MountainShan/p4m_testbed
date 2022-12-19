#!/usr/bin/python2
import os, sys, time
import subprocess
import random

from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI
from mininet.link import TCLink, Intf
from mininet.node import RemoteController, OVSSwitch
from p4_topology.p4_mininet import P4Host
from p4_topology.p4runtime_switch import P4RuntimeSwitch

os.chdir(os.path.dirname(os.path.realpath(__file__)))
def main():
	P4SwitchList = []
	HostList = []
	net = Mininet(controller = None, link = TCLink)
	Controller = RemoteController( 'Controller', ip='127.0.0.1', port=6633)
	
	for i in range(0,1):
		P4SwitchList.append(net.addSwitch("s%d"%(i+1), cls = P4RuntimeSwitch, device_id = i+1, sw_path="simple_switch_grpc", json_path="./p4_script/build/switch.json", cpu_port=255))
	for i in range(0,2):
		HostList.append(net.addHost("h%d"%(i+1), cls=P4Host, ip = "10.0.0.%d/24"%(i+11), mac = "00:04:00:00:00:%d"%(i+1)))
	
	# Topology
	for i in range(0,2):
		net.addLink(HostList[i], P4SwitchList[0], bw=100)

	net.start()
	CLI(net)
	net.stop()

if __name__ == "__main__":
	setLogLevel( "info" )
	main()
