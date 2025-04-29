-- Simple test to check if breakpoint key mapping works
-- Instructions:
--  1. Open this file in Neovim: nvim test_breakpoint.lua
--  2. Press your configured breakpoint key (F9 currently)
--  3. Look for a red dot in the gutter indicating a breakpoint

-- Function to print a message about this test
function test_function()
    -- Place cursor here when testing breakpoint toggling
    print("This is a test function!")
    print("Breakpoint test completed.")
    return true
end

-- Call the function
test_function()