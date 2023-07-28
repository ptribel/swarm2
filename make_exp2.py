import xml.etree.ElementTree as ET

def create_experimental_setup(script_filepath, algo_name, nb_ants, seed):
    # Load the XML file
    tree = ET.parse('tunnelling_1.argos')
    root = tree.getroot()

    def change_seed(seed):
        experiment_element = root.find('framework/experiment')
        if experiment_element is not None:
            experiment_element.set('random_seed', f"{seed}")

    def change_nb_ants(nb_ants):
        entity_element = root.find('arena/distribute/entity')
        if entity_element is not None:
            entity_element.set('quantity', f"{nb_ants}")

    def change_algorithm(algor_filepath):
        script_element = root.find('controllers/lua_controller/params')
        if script_element is not None:
            script_element.set('script', algor_filepath)

    def change_output_name(algo_name, nb_ants, seed):
        loop_functions = root.find('loop_functions')
        if loop_functions is not None:
            loop_functions.set('output', f"./experiments_settings/outputs/{algo_name}/size_{nb_ants}_seed_{seed}.txt")

    # Save the modified XML to a file
    change_seed(seed)
    change_nb_ants(nb_ants)
    change_algorithm(script_filepath)
    change_output_name(algo_name, nb_ants, seed)
    tree.write(f'tunnelling_1.argos')

import subprocess

def run_c_executable(executable_path, arguments):
    # Create a command list including the executable path and arguments
    command = [executable_path] + arguments

    try:
        # Execute the command without capturing output
        subprocess.run(command)
    except subprocess.CalledProcessError as e:
        # Handle any errors that occur during execution
        print(f"Error executing the C program: {e}")
        return None

# Example usage
executable_path = 'argos3'
arguments = ['-c', 'tunnelling_1.argos', '--logerr-file', '/dev/null']

sizes = list(range(40, 55, 5)) # [5, 7, 10, 17, 25, 37, 50, 75, 100]
for nb_ants in sizes:
    for seed in range(1,6):
        print(f"{nb_ants = } and {seed = }")
        create_experimental_setup("simple.lua", "simple", nb_ants, seed)
        run_c_executable(executable_path, arguments)
