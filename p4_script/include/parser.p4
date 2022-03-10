/* -*- P4_16 -*- */
/*  Implementing RTT Module @ P4
 *  Clone Packet
 *  V1Model Updata?
*/

# include <core.p4>
# include <v1model.p4>

const   bit<16>   ETHERNET_TYPE_ARP     =   16w0x0806;
const   bit<16>   ETHERNET_TYPE_IPV4    =   16w0x0800;

const   bit<8>  IP_PROTOCOL_TCP =   8w0x6;
const   bit<8>  IP_PROTOCOL_UDP =   8w0x11;


/* Header*/
struct metadata_t { 
    bit<16> l4_packet_length;
}

struct headers {
    ethernet_t ethernet;
    arp_rarp_t arp_rarp;
    arp_rarp_ipv4_t arp_rarp_ipv4;
    ipv4_t ipv4;
    tcp_t tcp;
    udp_t udp;
}

parser MyParser(packet_in packet, out headers hdr, inout metadata_t metadata, inout standard_metadata_t standard_metadata) {
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            ETHERNET_TYPE_ARP:  parse_arp_rarp;
            ETHERNET_TYPE_IPV4: parse_ipv4;
            default:            accept;
        }
    }
    
    state parse_arp_rarp {
        packet.extract(hdr.arp_rarp);
        transition select(hdr.arp_rarp.protoType) {
            ETHERNET_TYPE_IPV4:  arp_rarp_ipv4;
            default:    accept;
        }
    }
    state arp_rarp_ipv4 {
        packet.extract(hdr.arp_rarp_ipv4);
        transition accept;
    }
    
    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        metadata.l4_packet_length = hdr.ipv4.totalLen-16w20;
        transition select(hdr.ipv4.protocol) {
            IP_PROTOCOL_TCP:    parse_tcp;
            IP_PROTOCOL_UDP:    parse_udp;
            default:    accept;
        }
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        transition accept;
    }
    
    state parse_udp {
        packet.extract(hdr.udp);
        transition accept;
    }
}

control MyDeparser(packet_out packet, in headers hdr) { 
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.arp_rarp);
        packet.emit(hdr.arp_rarp_ipv4);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.tcp);
        packet.emit(hdr.udp);
    }
} 