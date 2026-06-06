require('common');
local chat = require('chat');
local json = require('json');

addon.name    = 'Search'
addon.author  = 'Fiveside'
addon.version = '0.1'
addon.desc    = 'An addon for searching your inventory for items, similar to find'


---@class ContainerSpec
---@field id integer The container id the game uses to reference this
---@field name string The name of the container for printing.

---@class SearchResult
---@field name string The name of the item we found
---@field location string The container we found it in
---@field count integer The number of items in this location

---The list of inventory containers players have.
---The order of this table is the order in which we will print results.
---@type ContainerSpec[]
local CONTAINERS = T{
    { id = 0,  name = "Inventory"},
    { id = 1,  name = "Safe" },
    { id = 9,  name = "Safe2" },
    { id = 2,  name = "Storage" },
    { id = 3,  name = "Temporary" },
    { id = 4,  name = "Locker" },
    { id = 5,  name = "Satchel" },
    { id = 6,  name = "Sack" },
    { id = 7,  name = "Case" },
    { id = 8,  name = "Wardrobe" },
    { id = 10, name = "Wardrobe2" },
    { id = 11, name = "Wardrobe3" },
    { id = 12, name = "Wardrobe4" },
    { id = 13, name = "Wardrobe5" },
    { id = 14, name = "Wardrobe6" },
    { id = 15, name = "Wardrobe7" },
    { id = 16, name = "Wardrobe8" },
};

local CONTAINERS_BY_GAME_ID = T{};
do
    for _, container in ipairs(CONTAINERS) do
        CONTAINERS_BY_GAME_ID[container.id] = container.name;
    end
end

ashita.events.register("load", "onload", function ()
end)

ashita.events.register("unload", "onunload", function ()
end);

ashita.events.register('command', 'oncommand', function(e)
    local commands = {'/find', '/where', '/whereis'};
    local searchTerm = '';
    for _, command in ipairs(commands) do
        if e.command:startswith(command) then
            searchTerm = e.command:sub(command:len()+1);
        end
    end
    if searchTerm == '' then
        return;
    end

    e.blocked = true

    -- Resolve any autotranslate entries in the string
    searchTerm = AshitaCore:GetChatManager():ParseAutoTranslate(searchTerm, true)
    searchTerm = searchTerm:clean();

    local containerResults = findInContainers(searchTerm);
    for _, result in ipairs(containerResults) do
        local countStr = '';
        if result.count > 1 then
            countStr = ' [' .. result.count .. ']';
        end
        print(chat.header(addon.name) .. result.location .. ': ' .. chat.color(chat.colors.LawnGreen, result.name) .. countStr);
    end

    -- Summarize
    local count = containerResults:map(function(v) return v.count; end):sum();
    print(chat.header(addon.name) .. chat.success('Found ' .. tostring(count) .. ' results.'));
end);

---@param searchTerm string The name of the item we're searching for
function findInContainers(searchTerm)
    local inventory = AshitaCore:GetMemoryManager():GetInventory();
    local resources = AshitaCore:GetResourceManager();

    ---@type SearchResult[]
    local searchResults = T{};
    for _, container in ipairs(CONTAINERS) do
        local containerResults = T{};

        -- I'd like to use GetContainerCount here, but for some reason
        -- the list of items in a container is sparse.
        -- it contains zeros and has valid indices above
        -- the number returned by GetContainerCount
        for slotId = 1, inventory:GetContainerCountMax(container.id) do
            local containerItem = inventory:GetContainerItem(container.id, slotId);
            if containerItem ~= nil and containerItem.Id > 0 then
                -- message ('Found item id: ' .. item.Id);
                local item = resources:GetItemById(containerItem.Id);
                local itemName = item.Name[1];
                if isMatchingItem(searchTerm, itemName) then
                    if containerResults[itemName] == nil then
                        containerResults[itemName] = 0;
                    end
                    containerResults[itemName] = containerResults[itemName] + containerItem.Count;
                end
            end
        end

        -- We want the serach results to be relatively consistent, so
        -- sort the results that we found in the current container before
        -- recording the results
        local sorted = containerResults:keys():sort():each(function (name)
            searchResults[#searchResults+1] = {
                name = name,
                count = containerResults[name],
                location = CONTAINERS_BY_GAME_ID[container.id],
            };
        end);
    end

    return searchResults;
end

---@param searchTerm string The name of the item we're looking for
---@param item string the string we're testing
function isMatchingItem(searchTerm, item)
    -- TODO: fuzzy search
    return item:clean():lower():contains(searchTerm:lower());
end