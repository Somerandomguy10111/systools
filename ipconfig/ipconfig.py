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

def translate_interface_name(interface_name):
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
        return "Bridge Interface"  # Add this condition for bridge interfaces
    else:
        return f"Unknown Adapter ({interface_name})"



def display_adapters(adapters):
    for interface, state in adapters:
        print(f"Adapter: {interface}, State: {state}")

adapters = get_network_adapters()
display_adapters(adapters)
