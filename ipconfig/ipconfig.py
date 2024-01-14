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

    print("sections: ", sections)

    for section in sections:
        if section.strip():
            new_adapter = Adapter.from_nmcli_output(section)
            adapter_list.append(new_adapter)


    return adapter_list

# Example usage
for adapter in get_adapters():
    print()
    print(adapter)
