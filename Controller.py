#!/usr/bin/env python2
import grpc, os, sys
from time import sleep
from threading import Thread 
# GRPC client
import p4_runtime.bmv2
import p4_runtime.helper
from p4_runtime.error_utils import printGrpcError

class P4_Controller:
    def __init__ (self, p4info_file, json_file):
        self.switches = {}
        self.p4info_file = p4info_file
        self.json_file = json_file

    def _write_rules(self, p4info):
        """ ... """
        table_entries = []
        """
        table_entries.append(
            (
                0,  # action (0 = Insert, 1 = Modify, 2 = Delete)
                0,  # messagae_type (0 = Flow entries)
                p4info.buildTableEntry(
                    table_name="",   # <control_block>.<table_name>
                    match_fields={ }, 
                    action_name="", # <control_block>.<action_name>
                    action_params={}
                )
            )
        )
        """
        return table_entries
    def _write_arp_forwarding_rules(self, p4info, source, destination, port):
        """ ... """
        table_entries = []
        table_entries.append((0, 0, p4info.buildTableEntry(
            table_name="MyIngress.arp_forwarding",
            match_fields={ "hdr.arp_rarp_ipv4.srcProtoAddr": source, "hdr.arp_rarp_ipv4.dstProtoAddr": destination}, 
            action_name="MyIngress.set_output",
            action_params={"port": port} )))
        return table_entries
    
    def _write_ipv4_forwarding_rules(self, p4info, source, destination, port):
        """ ... """
        table_entries = []
        table_entries.append((0, 0, p4info.buildTableEntry(
            table_name="MyIngress.ipv4_forwarding",
            match_fields={ "hdr.ipv4.srcAddr": source, "hdr.ipv4.dstAddr": destination}, 
            action_name="MyIngress.set_output",
            action_params={"port": port} )))
        return table_entries
    
    def arp_packet_handler(self, response):
        """ ... """
        pass
    
    # Packet process
    def packet_in_handler(self, sw_id):
        try:
            for response in self.switches[sw_id]["gRPC"].stream_msg_resp:
                if (response):
                    """
                    Message = response.packet.payload
                    Metadata = response.packet.metadata
                    self.arp_packet_handler(response)
                    """
                    self.switches[sw_id]["gRPC"].PacketOut(payload, metadata)
                    pass
        except grpc.RpcError as e:
            printGrpcError(e,sw_id)

    def main(self):
        threads = []
        try:
            for sw in range(1,5):
                p4info_helper = p4_runtime.helper.P4InfoHelper(self.p4info_file)
                grpc_client = p4_runtime.bmv2.Bmv2SwitchConnection(name = 's%d'%(sw),address = '127.0.0.1:%d'%(50050+sw),device_id = sw,low = 0)
                grpc_client.MasterArbitrationUpdate()
                grpc_client.SetConfigureForwardingPipeline(action = 2, p4info = p4info_helper.p4info, bmv2_json_file_path = self.json_file)
                self.switches.setdefault(sw, {"gRPC": grpc_client, "p4info": p4info_helper})
                threads.append(Thread(target=self.packet_in_handler, args=(sw, )))
                threads[-1].start()
            print(" >>> Start monitoring ports and flows. ")
            # Default Entries
            ''' ... '''
            fe = []
            sw = 1
            grpc_connection = self.switches[sw]["gRPC"]
            p4info = self.switches[sw]["p4info"]
            fe += self._write_arp_forwarding_rules(p4info, "10.0.0.11", "10.0.0.12", 2)
            fe += self._write_arp_forwarding_rules(p4info, "10.0.0.12", "10.0.0.11", 1)
            fe += self._write_ipv4_forwarding_rules(p4info, "10.0.0.11", "10.0.0.12", 2)
            fe += self._write_ipv4_forwarding_rules(p4info, "10.0.0.12", "10.0.0.11", 1)
            grpc_connection.WriteTableEntry(fe)
            # Waiting for packet in event
            while(True):
                sleep(1)
        
        except KeyboardInterrupt:
            print (" Shutting down.")
        except grpc.RpcError as e:
            printGrpcError(e, -1)
        finally:
            for sw_id in self.switches:
                self.switches[sw_id]['gRPC'].shutdown()
            for t in threads:
                t.join()

if __name__ == '__main__':
    P4Controller = P4_Controller("./p4_script/build/switch.p4info.txt", "./p4_script/build/switch.json")
    P4Controller.main()
