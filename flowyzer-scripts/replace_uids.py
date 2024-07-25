import re

class UIDGenerator:
    def __init__(self, start=990000):
        self.current = start

    def generate_unique_number(self):
        self.current += 1
        return f"{self.current}"

def replace_uid_in_values(values, uid_generator):
    # Split the values by commas, respecting JSON and string boundaries
    value_list = []
    current_value = ""
    in_string = False
    in_json = 0
    for char in values:
        if char == "'" and not in_json:
            in_string = not in_string
        elif char == "{" and not in_string:
            in_json += 1
        elif char == "}" and not in_string:
            in_json -= 1

        if char == "," and not in_string and in_json == 0:
            value_list.append(current_value.strip())
            current_value = ""
        else:
            current_value += char

    value_list.append(current_value.strip())  # append the last value

    date_pattern = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z')

    for i, value in enumerate(value_list):
        value = value.strip().strip("'")
        if i == 13 and not date_pattern.match(value):
            # Generate a new unique UID
            new_uid = uid_generator.generate_unique_number()
            # Replace the 14th value if it's not a date/time pattern
            value_list[i] = f"'{new_uid}'"

    return ", ".join(value_list)

def process_file(input_file, output_file, uid_generator):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            # Regex to find VALUES clause
            match = re.search(r'VALUES\s*\((.*)\)', line, re.DOTALL)
            if match:
                values = match.group(1)
                # Replace only the 14th value (uid)
                new_values = replace_uid_in_values(values, uid_generator)
                new_line = line.replace(values, new_values)
                outfile.write(new_line)
            else:
                outfile.write(line)

def main():
    # Read UIDs from values.txt
    with open('values.txt', 'r') as file:
        uid_list = [line.strip() for line in file.readlines()]

    # Create UID generator starting from 990000
    uid_generator = UIDGenerator(start=990000)

    # Process the task_input.sql file and save to task_input_updated.sql
    process_file('task_input.sql', 'task_input_updated.sql', uid_generator)

if __name__ == "__main__":
    main()