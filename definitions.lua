---@meta

---@alias containerId
---| integer An id representing an in-game inventory container

---@class ContainerSpec
---@field id containerId The container id the game uses to reference this
---@field name string The name of the container for printing.

---@class SearchResult
---@field item IItem The item itself
---@field count integer The number of items in this search slot
---@field location string The display name of the container or location we found this in.
---@field instance? item_t This is present if this is a concrete item in our inventory.