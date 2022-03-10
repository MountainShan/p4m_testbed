/* -*- P4_16 -*- */
# include <core.p4>
# include <v1model.p4>

typedef bit<48>  macAddr_t;
typedef bit<32>  ip4Addr_t;
typedef bit<9>   PortID_t;
typedef bit<32>  SessionID_t;

@controller_header("packet_in")
header  packet_in_header_t {
    bit<64>     preamble;
    bit<16>     device_id;
    bit<16>     header_type;
    bit<16>     port;
}

@controller_header("packet_out")
header  packet_out_header_t {
    bit<64>     preamble;
    bit<16>     device_id;
    bit<16>     header_type;
    bit<16>     port;
}

header ethernet_t {
    macAddr_t   dstAddr;
    macAddr_t   srcAddr;
    bit<16>     etherType;
}

header arp_rarp_t {
    bit<16>     hwtype;
    bit<16>     protoType;
    bit<8>      hwAddrLen;
    bit<8>      protoAddrLen;
    bit<16>     opcode;
}

header arp_rarp_ipv4_t {
    macAddr_t   srcHwAddr;
    ip4Addr_t   srcProtoAddr;
    macAddr_t   dstHwAddr;
    ip4Addr_t   dstProtoAddr;
}

header ipv4_t {
    bit<4>      version;
    bit<4>      ihl;
    bit<8>      diffserv;
    bit<16>     totalLen;
    bit<16>     identification;
    bit<3>      flags;
    bit<13>     fragOffset;
    bit<8>      dscp;
    bit<8>      protocol;
    bit<16>     hdrChecksum;
    ip4Addr_t   srcAddr;
    ip4Addr_t   dstAddr;
}

header udp_t {
    bit<16>     srcPort;
    bit<16>     dstPort;
    bit<16>     length;
    bit<16>     checksum;
}

header tcp_t {
    bit<16>     srcPort;
    bit<16>     dstPort;
    bit<32>     seqNo;
    bit<32>     ackNo;
    bit<4>      dataOffset;
    bit<4>      res;
    bit<8>      flags;
    bit<16>     window;
    bit<16>     checksum;
    bit<16>     urgentPtr;
}
