from adapter import Adapter

import subprocess
import re

def get_network_adapters():
    result = subprocess.run(['ip', 'link', 'show'], stdout=subprocess.PIPE)
    output = result.stdout.decode('utf-8')

    regex = r"(\d+): (\w+):.*state (\w+)"
    matches = re.finditer(regex, output, re.MULTILINE)

    adapters = []
    for match in matches:
        interface = match.group(2)
        state = match.group(3)
        friendly_name = translate_interface_name(interface)
        adapters.append((friendly_name, state))

    return adapters




def get_adapters() -> list[Adapter]:
    command = "nmcli device show"
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    if error:
        raise Exception(f"Error executing nmcli: {error.decode()}")

    adapter_list : list[Adapter] = []
    sections = "".join(output.decode()).split("\n\n")
    for section in sections:
        if section.strip():
            new_adapter = Adapter.from_nmcli_output(section)
            adapter_list.append(new_adapter)


    return adapter_list

# Example usage
for adapter in get_adapters():
    print()
    print(adapter)
