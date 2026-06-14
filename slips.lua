
local SlipData = require('slipdata/slips');
local Containers = require('containers');
local json = require('json');

---Maps a slip id to the SlipData entry for this slip
local SLIP_IDS = T{};
do
    for idx, data in ipairs(SlipData) do
        SLIP_IDS[data.item_id] = data;
    end
end

---A sparse list of concrete inventory items for each porter slip we have.
---@type table<integer, item_t> Slip items indexed by their item id.
local SLIP_LOCATIONS = T{}

local Export = {};

---Updates our cache of slip items with this candidate item.  Only updates slip items
---and ignores all others.
---@param candidateItem item_t
function Export.updateSlips(candidateItem)
    if SLIP_IDS[candidateItem.Id] ~= nil then
        SLIP_LOCATIONS[candidateItem.Id] = candidateItem;
    end
end

---@return fun(table: integer[], i?: integer):integer, integer
---@return integer[]
---@return integer
function listPossibleSlipContents(slipNumber);
    local slip = SlipData[slipNumber];
    return ipairs(slip.items);
end

---@return fun(table: integer[], i?: integer):integer, integer
---@return integer[]
---@return integer
function possibleSlipContentsIterator(slipNumber);
    local slip = SlipData[slipNumber];
    return ipairs(slip.items);
end

---@param slipNumber integer invariant
---@param index integer
---@return integer?, {item: IItem, count: integer, location: string}?
function ownedSlipContentsIterator(slipNumber, index)
    local resources = AshitaCore:GetResourceManager();
    local data = SlipData[slipNumber];
    local slip = SLIP_LOCATIONS[data.item_id];
    for i = index, #data.items do
        -- Presence of an item in a slip is done by interpreting the extra
        -- data as a bitfield.
        local byteIndex = math.modf((i-1) / 8) + 1;
        local bitmask = 2 ^ ((i-1) % 8);
        if bit.band(string.byte(slip.Extra, byteIndex), bitmask) > 0 then
            local itemId = data.items[i];
            local item = resources:GetItemById(itemId);
            return i+1, {item=item, count=1, location=data.en}
        end
    end
end

---Accepts a stateless iterator that accepts an invariant and returns an iterator
---with the same functionality but that accepts a list of the same type of invariant.
---@generic T Iterator invariant
---@generic S Iterator inner state
---@generic R Iterator return type
---@param iterFn fun(T, S): S, R
---@param innerFact fun(): S
---@return fun(invariant: T[], state: {outer: integer, inner: S}): {outer: integer, inner: S}, R
function ichainIterator(iterFn, innerFact)
    return function(invariant, state)
        for i = state.outer, #invariant do
            local nextInner, nextResult = iterFn(invariant[i], state.inner)
            if nextInner ~= nil then
                return {outer = i, inner = nextInner}, nextResult
            end
            -- We've exhausted this entry in the invariant list, so reset the inner state
            state.inner = innerFact()
        end
    end
end

---@return fun(table: integer[], i?: integer):integer, {item: IItem, count: integer, location: string}
---@return integer[]
---@return {outer: integer, inner: integer}
function Export.listOwnedSlipContents()
    local slipNums = {}
    for i, data in ipairs(SlipData) do
        if SLIP_LOCATIONS[data.item_id] ~= nil then
            slipNums[#slipNums+1] = i
        end
    end
    local fact = function() return 1; end;
    return ichainIterator(ownedSlipContentsIterator, fact), slipNums, {outer=1, inner=fact()}
end
return Export;