require('common');

---@type integer[]
local KEY_ITEM_IDS = T {};

-- Discover which key items resolve to a name.
-- 4096 is just a sanity number.  At the time of writing there
-- are less than 4096 possible key items.

-- Keep the key item ids in a list sorted by alphabetical
-- order of the key item name, so that when we iterate
-- later they stay sorted.
do
    local keyItems = T {};
    for id = 1, 4096 do
        local resources = AshitaCore:GetResourceManager();
        local res = resources:GetString("keyitems.names", id);
        if res ~= nil then
            keyItems[#keyItems + 1] = { id = id, name = res };
        end
    end

    table.sort(keyItems, function(a, b)
        return a.name:lower() < b.name:lower();
    end)
    for _, ki in ipairs(keyItems) do
        KEY_ITEM_IDS[#KEY_ITEM_IDS + 1] = ki.id;
    end
end

---A stateless iterator that yields only key items that the player actually has
---@param invariant integer[]
---@param index integer
---@return integer?, {id: integer, name: string}?
function ownedKeyItemIterator(invariant, index)
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    local resources = AshitaCore:GetResourceManager();

    while index <= #invariant do
        local id = invariant[index];
        index = index + 1;
        if player:HasKeyItem(id) then
            return index, {
                id = id,
                name = resources:GetString('keyitems.names', id),
            };
        end
    end
end

local Export = {};

---A statelist iterator returning only key items the player owns in alphabetical order.
---@return fun(): integer, {id: integer, name: string}
---@return integer[]
---@return integer
function Export.listObtained()
    return ownedKeyItemIterator, KEY_ITEM_IDS, 1
end

return Export;
