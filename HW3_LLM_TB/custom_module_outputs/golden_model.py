def sat_adder4_golden(a, b):
    # Ensure inputs are within the 4-bit unsigned range
    assert 0 <= a <= 15, "Input 'a' must be a 4-bit unsigned number (0 to 15)"
    assert 0 <= b <= 15, "Input 'b' must be a 4-bit unsigned number (0 to 15)"
    
    # Calculate the sum
    result = a + b
    
    # Determine if saturation is needed
    if result > 15:
        sum_result = 15
        sat = 1
    else:
        sum_result = result
        sat = 0
    
    # Return the results as a dictionary
    return {'sum': sum_result, 'sat': sat}