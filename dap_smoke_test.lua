-- DAP smoke test
-- Save this to a file and run `:luafile %` to execute
--
-- Note: When running in headless mode, keymaps may not be detected properly
-- even though they are correctly configured. In normal Neovim sessions,
-- the F9 key mapping should work correctly.

-- Check for Packer installation of nvim-dap
print("Checking if nvim-dap plugin directory exists...")
local plugin_path = vim.fn.stdpath('data')..'/site/pack/packer/start/nvim-dap'
if vim.fn.isdirectory(plugin_path) == 1 then
  print("✓ nvim-dap plugin directory exists at " .. plugin_path)
else
  print("❌ nvim-dap plugin directory does NOT exist")
end

-- Look for loaded dap modules
print("\nLoaded DAP modules:")
local found_dap_module = false
for k,_ in pairs(package.loaded) do
  if k:match("dap") then
    print("  - " .. k)
    found_dap_module = true
  end
end
if not found_dap_module then
  print("  None found")
end

-- Try loading the dap module
print("\nTrying to load nvim-dap...")
local has_dap, dap = pcall(require, 'dap')
if not has_dap then
  print("❌ nvim-dap is NOT loaded properly: " .. tostring(dap))
  return
end

print("✓ nvim-dap is loaded")

-- Test if breakpoint functions exist
if type(dap.toggle_breakpoint) == "function" then
  print("✓ dap.toggle_breakpoint function exists")
else
  print("❌ dap.toggle_breakpoint function NOT found")
end

-- Check key mapping
local result = vim.fn.mapcheck('<F9>', 'n')
if result ~= "" then
  print("✓ F9 mapping is configured: " .. result)
else
  print("❌ F9 mapping NOT found")
end

-- Check if signs are defined
local signs = {"DapBreakpoint", "DapBreakpointCondition", "DapLogPoint", "DapStopped"}
for _, sign in ipairs(signs) do
  local sign_defined = vim.fn.sign_getdefined(sign)
  if #sign_defined > 0 then
    print("✓ Sign '" .. sign .. "' is defined")
  else
    print("❌ Sign '" .. sign .. "' is NOT defined")
  end
end