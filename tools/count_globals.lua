-- Returns just the count of string-keyed entries in _G and the
-- byte-size their enum_globals-style dump would produce. Useful for
-- deciding whether the full dump fits the bridge's 4 KB result cap or
-- needs to be paginated.
local count = 0
local total_bytes = 0
for k, v in pairs(_G) do
  if type(k) == "string" then
    count = count + 1
    -- Each enum_globals line is "<type>\t<key>\n"
    total_bytes = total_bytes + #type(v) + 1 + #k + 1
  end
end
return string.format("_G has %d string keys, dump would be ~%d bytes", count, total_bytes)
