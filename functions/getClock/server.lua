local isWindows = os.getenv("OS") == "Windows"
local multiplier = isWindows and 1 or 10

---Returns os.clock() with platform-specific correction for Linux systems, it seems that Linux systems returns ~0.1s every 1s
---@return number
function Functions.getClock()
    return os.clock() * multiplier
end

return Functions.getClock