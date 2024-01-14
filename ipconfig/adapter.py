class Adapter:
    def __init__(
        self,
        name: str,
        adapter_type: str,
        dns_suffix: str,
        ipv4_address: str,
        ipv6_address: str,
        subnet_mask: str,
        default_gateway: str
    ) -> None:
        self.name: str = name
        self.adapter_type: str = adapter_type
        self.dns_suffix: str = dns_suffix
        self.ipv4_address: str = ipv4_address
        self.ipv6_address: str = ipv6_address
        self.subnet_mask: str = subnet_mask
        self.default_gateway: str = default_gateway


    def get_formatted_name(self):
        return f"{self.get_formatted_label('Name')}{self.name}"

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
        formatted_info = [
            self.get_formatted_name(),
            self.get_formatted_type(),
            self.get_formatted_dns_suffix(),
            self.get_formatted_ipv4(),
            self.get_formatted_ipv6(),
            self.get_formatted_subnet_mask(),
            self.get_formatted_default_gateway()
        ]
        return "\n".join(formatted_info)

    @staticmethod
    def get_formatted_label(label):
        target_size = 30
        blank_padding = " " * (target_size - len(label))
        dotted_padding = ''.join([c if (i+len(label)) % 2 == 0 else '.' for i, c in enumerate(blank_padding)])
        adjusted_label = f"{label}{dotted_padding}"[:target_size] + " : "
        return adjusted_label


# Example usage:
adapter = Adapter(
    name="Ethernet Adapter",
    adapter_type="Ethernet",
    dns_suffix="example.com",
    ipv4_address="192.168.1.100",
    ipv6_address="2001:0db8:85a3:0000:0000:8a2e:0370:7334",
    subnet_mask="255.255.255.0",
    default_gateway="192.168.1.1"
)

print(adapter)
