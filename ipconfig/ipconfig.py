from adapter import Adapter
import subprocess


def get_adapters() -> list[Adapter]:
    command = "nmcli device show"
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    if error:
        raise Exception(f"Error executing nmcli: {error.decode()}")

    adapter_list : list[Adapter] = []
    sections = "".join(output.decode()).split("\n\n")

    # print("sections: ", sections)

    for section in sections:
        if section.strip():
            new_adapter = Adapter.from_nmcli_output(section)
            adapter_list.append(new_adapter)


    return adapter_list

# Example usage
for adapter in get_adapters():
    print()
    print(adapter)


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
