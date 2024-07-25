import re

def extract_values_from_sql(sql):
    # Regex to extract the values part of the SQL statement
    match = re.search(r'VALUES\s*\((.*)\)', sql, re.DOTALL)
    if match:
        values_part = match.group(1)
        # Split the values by commas, respecting JSON and string boundaries
        values = []
        current_value = ""
        in_string = False
        in_json = 0
        for char in values_part:
            if char == "'" and not in_json:
                in_string = not in_string
            elif char == "{" and not in_string:
                in_json += 1
            elif char == "}" and not in_string:
                in_json -= 1

            if char == "," and not in_string and in_json == 0:
                values.append(current_value.strip())
                current_value = ""
            else:
                current_value += char
        
        values.append(current_value.strip())  # append the last value
        return values
    return []

def main():
    # Read the SQL statements from the file
    with open('task_input.sql', 'r') as file:
        sql_statements = file.readlines()

    # Open the output file
    with open('values.txt', 'w') as outfile:
        for sql_statement in sql_statements:
            # Extract values from the SQL statement
            values = extract_values_from_sql(sql_statement)

            # Check if there are enough values to get the 14th (uid) value
            if len(values) >= 14:
                uid_value = values[13].strip().strip("'")
                # Write the extracted 'uid' value to the values.txt file
                outfile.write(uid_value + '\n')

if __name__ == "__main__":
    main()