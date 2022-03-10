# include <core.p4>
# include <v1model.p4>

# include "include/header.p4"
# include "include/parser.p4"

control MyVerifyChecksum(inout headers hdr, inout metadata_t metadata) { apply {  } }

control MyIngress(inout headers hdr,inout metadata_t metadata,inout standard_metadata_t standard_metadata) { 
    action drop () { 
        mark_to_drop(standard_metadata); 
    }
    action set_output (PortID_t port) {
        standard_metadata.egress_spec = port;
    }
    action packet_in_message (PortID_t port) {
        standard_metadata.egress_spec = port;
    }
    /*
    table <table_name> {
        key = {
            <match info>: <compare type>;
        }
        actions = {
            <action_name>;
        }
        default_action = <action_name>(<input>);
    }
    */
    table arp_forwarding {
        key = {
            hdr.arp_rarp_ipv4.srcProtoAddr: exact;
            hdr.arp_rarp_ipv4.dstProtoAddr: exact;
        } 
        actions = {
            drop;
            set_output;
        }
        default_action = drop();
    }
    table ipv4_forwarding {
        key = {
            hdr.ipv4.srcAddr: exact;
            hdr.ipv4.dstAddr: exact;
        } 
        actions = {
            drop;
            set_output;
        }
        default_action = drop();
    }
    apply { 
        /*
        <action_name>.apply();
        */
        if (hdr.ipv4.isValid())
            ipv4_forwarding.apply();
        else if (hdr.arp_rarp_ipv4.isValid())
            arp_forwarding.apply();
    }
} 

control MyEgress(inout headers hdr,inout metadata_t metadata,inout standard_metadata_t standard_metadata) {  apply {  } }

control MyComputeChecksum(inout headers  hdr, inout metadata_t metadata) { 
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            { 
                hdr.ipv4.version,
                hdr.ipv4.ihl,
                hdr.ipv4.diffserv,
                hdr.ipv4.totalLen,
                hdr.ipv4.identification,
                hdr.ipv4.flags,
                hdr.ipv4.fragOffset,
                hdr.ipv4.dscp,
                hdr.ipv4.protocol,
                hdr.ipv4.srcAddr,
                hdr.ipv4.dstAddr 
            },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16
        );
    }
}

V1Switch( MyParser(), MyVerifyChecksum(), MyIngress(), MyEgress(), MyComputeChecksum(), MyDeparser() ) main;