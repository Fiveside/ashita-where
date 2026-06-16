require('common');
local chat       = require('chat');
local KeyItems   = require('keyitems');
local Slips      = require('slips');
local Containers = require('containers');

---@module 'definitions'

addon.name       = 'Where'
addon.author     = 'Fiveside'
addon.version    = '0.1'
addon.desc       = 'An addon for searching your inventory for items, similar to find'

ashita.events.register("load", "onload", function()
end);

ashita.events.register("unload", "onunload", function()
end);


---Takes a full command and splits it into the slash command,
---a rich version of the arguments, and a clean version of the arguments
---@param command string The full command being invoked
---@return string? Just the slash command
---@return string? The rich arguments
---@return string? The sanitized arguments
function cleanCommand(command)
    local idx = string.find(command, '%s');
    if idx == nil then
        return nil
    end
    local slashCommand = command:sub(1, idx - 1):clean();
    local richArgs = command:sub(idx + 1):clean();

    -- Resolve any autotranslate entries in the string
    local sanitized = AshitaCore:GetChatManager():ParseAutoTranslate(richArgs, true);
    sanitized = sanitized:strip_colors():strip_translate(false):clean();
    return slashCommand, richArgs, sanitized;
end

ashita.events.register('command', 'oncommand', function(e)
    local command, rich, sanitized = cleanCommand(e.command);
    local commands = T { '/find', '/where', '/whereis' };
    if command == nil or not commands:contains(command) then
        return;
    end

    -- Nil already checked for command, and cleanCommand only returns all nil or all string
    ---@cast rich string
    ---@cast sanitized string

    e.blocked = true

    local numResults = 0;

    ---@type table<string, table<string, integer>>
    local containerResults = T {};
    for _, name in pairs(Containers.CONTAINER_NAMES) do
        containerResults[name] = T {};
    end

    for _, result in Containers.listAllContainers() do
        Slips.updateSlips(result.instance);
        local name = result.item.Name[1];
        if isMatchingItem(sanitized, name) then
            local resultCount = containerResults[result.location][name];
            if resultCount == nil then
                resultCount = 0;
            end
            containerResults[result.location][name] = resultCount + result.count;
        end
    end

    for _, container in ipairs(Containers.CONTAINERS) do
        local searchRes = containerResults[container.name];
        local names = searchRes:keys();
        table.sort(names);
        for _, name in ipairs(names) do
            local count = searchRes[name];
            local countStr = '';
            if count > 1 then
                countStr = ' [' .. count .. ']';
            end
            numResults = numResults + count;
            print(table.concat({
                chat.header(addon.name),
                container.name,
                ": ",
                chat.color(chat.colors.LawnGreen, name),
                countStr
            }));
        end
    end

    for _, result in Slips.listOwnedSlipContents() do
        if isMatchingItem(sanitized, result.item.Name[1]) then
            numResults = numResults + 1;
            -- print(chat.header(addon.name) .. chat.color(chat.colors.LawnGreen, result.location) .. ': ' .. result.item.Name[1])
            print(table.concat({
                chat.header(addon.name),
                chat.color(chat.colors.LawnGreen, result.location),
                ': ',
                result.item.Name[1],
            }))
        end
    end

    for _, ki in KeyItems.listObtained() do
        if isMatchingItem(sanitized, ki.name) then
            numResults = numResults + 1;
            print(chat.header(addon.name) .. 'Key Item: ' .. chat.color(chat.colors.RoyalBlue, ki.name));
        end
    end

    -- Summarize
    -- local count = containerResults:map(function(v) return v.count; end):sum();
    -- print(chat.header(addon.name) .. chat.success('Found ') .. tostring(numResults) .. chat.success(' results for ') .. rich .. chat.success('.'));
    print(table.concat({
        chat.header(addon.name),
        chat.success('Found '),
        tostring(numResults),
        chat.success(' results for '),
        rich,
        chat.success('.'),
    }));
end);

---@param searchTerm string The name of the item we're looking for
---@param item string the string we're testing
function isMatchingItem(searchTerm, item)
    -- TODO: fuzzy search
    return item:clean():lower():contains(searchTerm:lower());
end
