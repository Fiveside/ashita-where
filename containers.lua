local Export = {};

---@alias containerId
---| integer An id representing an in-game inventory container

---@class ContainerSpec
---@field id containerId The container id the game uses to reference this
---@field name string The name of the container for printing.

---The list of inventory containers players have.
---The order of this table is the order in which we will print results.
---@type ContainerSpec[]
Export.CONTAINERS = T {
    { id = 3,  name = "Temporary" },
    { id = 0,  name = "Inventory" },
    { id = 1,  name = "Safe" },
    { id = 9,  name = "Safe2" },
    { id = 2,  name = "Storage" },
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

---A mapping of container ids to their english names
Export.CONTAINER_NAMES = T{}
do
    for _, container in ipairs(Export.CONTAINERS) do
        Export.CONTAINER_NAMES[container.id] = container.name;
    end
end


---A stateless iterator that yields every item in the container specified;
---@param container containerId The id of the container we're looking through (Iterator Invariant)
---@param index integer The slot id of the container that we're currently inspecting
---@return integer?, {item: IItem, instance: item_t}?
function containerIterator(container, index)
    local inventory = AshitaCore:GetMemoryManager():GetInventory();
    local resources = AshitaCore:GetResourceManager();

    while index < inventory:GetContainerCountMax(container) do
        local containerItem = inventory:GetContainerItem(container, index);
        index = index + 1
        if containerItem ~= nil and containerItem.Id > 0 then
            local item = resources:GetItemById(containerItem.Id);
            return index, { item = item, instance = containerItem };
        end
    end
end

---An iterator over all items in a container
---@param container containerId
---@return fun(): integer, {item: IItem, instance: item_t}
---@return containerId
---@return integer
function Export.listContainerContents(container)
    return containerIterator, container, 1
end

---A stateless iterator that yields every item in our inventory
---@param containers containerId[]
---@param index {container: integer, index: integer}
function inventoryIterator(containers, index)
    for cid = index.container, #containers do
        local iid, item = containerIterator(cid, index.index)
        if iid ~= nil then
            index.index = iid;
            return index, item;
        end
        --We finished with this container, reset our index for the next
        index = {container=index.container+1, index=1}
    end
end

---An iterator returning each item in our inventory
function Export.listAllContainers()
    return inventoryIterator, Export.CONTAINERS:map(function(x) return x.id end), {container=1, index=1}
end


return Export;