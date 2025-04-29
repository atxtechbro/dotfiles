def factorial(n):
    """Calculate factorial of n recursively."""
    if n <= 1:
        return 1
    return n * factorial(n-1)

def fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fibonacci(n-1) + fibonacci(n-2)

def main():
    # Variables to inspect during debugging
    name = "Test User"
    numbers = [1, 2, 3, 5, 8, 13]
    user_data = {
        "id": 12345,
        "email": "test@example.com",
        "preferences": {
            "theme": "dark",
            "notifications": True
        }
    }
    
    # Try setting a breakpoint here with F9
    print(f"Hello, {name}!")
    
    # Try setting a conditional breakpoint here with <leader>B
    # Condition example: n > 5
    for n in numbers:
        result = factorial(n)
        print(f"Factorial of {n} is {result}")
    
    # Try setting a logpoint here with <leader>lp
    # Message example: "Calculating fibonacci({n}) = {fibonacci(n)}"
    for n in range(10):
        result = fibonacci(n)
        print(f"Fibonacci {n} = {result}")

if __name__ == "__main__":
    main()