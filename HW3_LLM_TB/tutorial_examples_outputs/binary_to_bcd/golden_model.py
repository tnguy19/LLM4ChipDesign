def binary_to_bcd_converter_golden(binary_input):
    # Initialize BCD output to zero
    bcd_output = 0

    # Extract the binary input value
    temp = binary_input & 0b11111  # Ensure it's 5-bits

    # Calculate tens and ones place for BCD
    tens = temp // 10
    ones = temp % 10

    # Assign the BCD output
    bcd_output = (tens << 4) | ones

    # Return the result as a dictionary
    return {'bcd_output': bcd_output}

# Example usage:
# result = binary_to_bcd_converter_golden(0b10101)
# print(result)  # {'bcd_output': 37} which is 0x25 in hex (2 tens, 5 ones)