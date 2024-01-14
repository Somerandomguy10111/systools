from __future__ import annotations
from typing import Optional

class Adapter:

    @classmethod
    def from_nmcli_output(cls,section: str) -> Adapter:
        the_adapter = Adapter()
        for line in section.split('\n'):
            if ':' not in line:
                continue
            key, value = line.split(':', 1)
            value = value.strip()

            if key == "GENERAL.DEVICE":
                the_adapter.name = value
            elif key == "GENERAL.TYPE":
                the_adapter.adapter_type = value
            elif key == "IP4.ADDRESS[1]":
                the_adapter.ipv4_address = value.split('/')[0]
                the_adapter.subnet_mask = value.split('/')[1] if '/' in value else None
            elif key == "IP4.GATEWAY":
                the_adapter.default_gateway = value
            elif key == "IP6.ADDRESS[1]":
                the_adapter.ipv6_address = value.split('/')[0]

        return the_adapter

    def __init__(
        self,
        technical_name: Optional[str] = None,
        adapter_type: Optional[str] = None,
        dns_suffix: Optional[str] = None,
        ipv4_address: Optional[str] = None,
        ipv6_address: Optional[str] = None,
        subnet_mask: Optional[str] = None,
        default_gateway: Optional[str] = None
    ) -> None:
        self.name: Optional[str] = technical_name
        self.adapter_type: Optional[str] = adapter_type
        self.dns_suffix: Optional[str] = dns_suffix
        self.ipv4_address: Optional[str] = ipv4_address
        self.ipv6_address: Optional[str] = ipv6_address
        self.subnet_mask: Optional[str] = subnet_mask
        self.default_gateway: Optional[str] = default_gateway



    def get_name(self):
        friendly_name = self.get_friendly_name(self.name)
        return friendly_name

    def get_formatted_type(self):
        return f"{self.get_formatted_label('Type')}{self.adapter_type}"

    def get_formatted_dns_suffix(self):
        return f"{self.get_formatted_label('DNS Suffix')}{self.dns_suffix}"

    def get_formatted_ipv4(self):
        return f"{self.get_formatted_label('IPv4 Address')}{self.ipv4_address}"

    def get_formatted_ipv6(self):
        return f"{self.get_formatted_label('IPv6 Address')}{self.ipv6_address}"

    def get_formatted_subnet_mask(self):
        return f"{self.get_formatted_label('Subnet Mask')}{self.subnet_mask}"

    def get_formatted_default_gateway(self):
        return f"{self.get_formatted_label('Default Gateway')}{self.default_gateway}"

    def __str__(self):
        indent = 2 * ' '
        formatted_info = [
            self.get_name(),
            '',
            f'{indent}{self.get_formatted_type()}',
            f'{indent}{self.get_formatted_dns_suffix()}',
            f'{indent}{self.get_formatted_ipv4()}',
            f'{indent}{self.get_formatted_ipv6()}',
            f'{indent}{self.get_formatted_subnet_mask()}',
            f'{indent}{self.get_formatted_default_gateway()}'
        ]
        return "\n".join(formatted_info)

    @staticmethod
    def get_formatted_label(label):
        target_size = 30
        blank_padding = " " * (target_size - len(label))
        dotted_padding = ''.join([c if (i+len(label)) % 2 == 0 else '.' for i, c in enumerate(blank_padding)])
        adjusted_label = f"{label}{dotted_padding}"[:target_size] + " : "
        return adjusted_label

    @staticmethod
    def get_friendly_name(interface_name : str) -> str:
        if interface_name.startswith('en'):
            return "Ethernet Adapter"
        elif interface_name.startswith('wl'):
            return "Wireless LAN Adapter"
        elif interface_name.startswith('virbr'):
            return "Virtual Bridge Interface"
        elif interface_name.startswith('veth'):
            return "Virtual Ethernet Interface"
        elif interface_name.startswith('tun') or interface_name.startswith('tap'):
            return "VPN Tunnel Interface"
        elif interface_name.startswith('bond'):
            return "Bonding Interface"
        elif '.' in interface_name:
            return "VLAN Interface"
        elif interface_name == 'lo':
            return "Loopback Interface"
        elif interface_name.startswith('br'):
            return "Bridge Interface"
        else:
            return f"Unknown Adapter ({interface_name})"


if __name__ == "__main__":
    adapter = Adapter(
        technical_name="Ethernet Adapter",
        adapter_type="Ethernet",
        dns_suffix="example.com",
        ipv4_address="192.168.1.100",
        ipv6_address="2001:0db8:85a3:0000:0000:8a2e:0370:7334",
        subnet_mask="255.255.255.0",
        default_gateway="192.168.1.1"
    )

    print(adapter)
