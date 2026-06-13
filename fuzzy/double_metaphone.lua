
---An implementation of the double metaphone algorithm in pure lua
---@param input string The string to transform
---@return {[1]: string, [2]: string}
function doubleMetaphone(input)
    if not input or input == "" then
        return {"", ""}
    end

    -- Convert to uppercase and clean
    local str = string.upper(input)
    
    -- Initialize primary and secondary keys
    local primary = ""
    local secondary = ""
    local length = #str
    local index = 1
    
    -- Helper function to get character at position
    local function getChar(pos)
        if pos < 1 or pos > length then return "" end
        return string.sub(str, pos, pos)
    end
    
    -- Helper function to check if substring matches at position
    local function matchAt(pos, patterns)
        if type(patterns) == "string" then
            patterns = {patterns}
        end
        for _, pattern in ipairs(patterns) do
            if string.sub(str, pos, pos + #pattern - 1) == pattern then
                return true
            end
        end
        return false
    end
    
    -- Helper function to check if character is vowel
    local function isVowel(char)
        return char == "A" or char == "E" or char == "I" or char == "O" or char == "U" or char == "Y"
    end
    
    -- Skip leading non-alphabetic characters and handle special prefixes
    while index <= length and not string.match(getChar(index), "[A-Z]") do
        index = index + 1
    end
    
    -- Handle special first letters
    local firstChar = getChar(index)
    if firstChar == "K" or firstChar == "G" or firstChar == "P" or firstChar == "W" or firstChar == "H" then
        if index == 1 and getChar(2) == "N" then
            if firstChar == "K" or firstChar == "G" then
                primary = "N"
                secondary = "N"
            end
        end
    end
    
    if firstChar == "W" and getChar(2) == "R" then
        primary = "R"
        secondary = "R"
        index = index + 2
    elseif firstChar == "X" then
        primary = "S"
        secondary = "S"
        index = index + 1
    elseif firstChar == "H" and isVowel(getChar(2)) then
        primary = getChar(2)
        secondary = getChar(2)
        index = index + 2
    elseif firstChar == "A" then
        primary = "A"
        secondary = "A"
        index = index + 1
    else
        if primary == "" then
            primary = firstChar
            secondary = firstChar
        end
        index = index + 1
    end
    
    -- Process remaining characters
    while index <= length do
        local char = getChar(index)
        local nextChar = getChar(index + 1)
        
        if char == "A" or char == "E" or char == "I" or char == "O" or char == "U" or char == "Y" then
            if index == 1 then
                primary = primary .. char
                secondary = secondary .. char
            end
            index = index + 1
        elseif char == "B" then
            if not (index + 1 > length and getChar(index - 1) == "M") then
                primary = primary .. "P"
                secondary = secondary .. "P"
            end
            if nextChar == "B" then
                index = index + 2
            else
                index = index + 1
            end
        elseif char == "C" then
            if index > 1 and not isVowel(getChar(index - 1)) and getChar(index - 1) ~= "" and getChar(index - 1) ~= "A" and getChar(index - 1) ~= "O" and getChar(index - 1) ~= "U" then
                if nextChar == "H" then
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                    index = index + 2
                else
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                    index = index + 1
                end
            elseif index == 1 and matchAt(index, "CAESAR") then
                primary = primary .. "S"
                secondary = secondary .. "S"
                index = index + 1
            elseif matchAt(index, {"CH"}) then
                if index > 1 and matchAt(index - 1, {"S", "T", "C"}) then
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                else
                    primary = primary .. "X"
                    secondary = secondary .. "X"
                end
                index = index + 2
            elseif matchAt(index, "CZ") and not matchAt(index - 2, "WI") then
                primary = primary .. "S"
                secondary = secondary .. "X"
                index = index + 2
            elseif matchAt(index + 1, "CIA") then
                primary = primary .. "X"
                secondary = secondary .. "X"
                index = index + 3
            elseif nextChar == "C" and not (index + 2 <= length and getChar(index + 2) == "E") then
                primary = primary .. "K"
                secondary = secondary .. "K"
                index = index + 2
            else
                if nextChar == "E" or nextChar == "I" or nextChar == "Y" then
                    primary = primary .. "S"
                    secondary = secondary .. "S"
                else
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                end
                index = index + 1
            end
        elseif char == "D" then
            if nextChar == "G" and (index + 2 <= length and (getChar(index + 2) == "E" or getChar(index + 2) == "I" or getChar(index + 2) == "Y")) then
                primary = primary .. "J"
                secondary = secondary .. "J"
                index = index + 3
            else
                primary = primary .. "T"
                secondary = secondary .. "T"
                index = index + 1
            end
        elseif char == "G" then
            if nextChar == "H" then
                if index > 1 and not isVowel(getChar(index - 1)) then
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                    index = index + 2
                elseif index == 1 then
                    if getChar(index + 2) == "I" then
                        primary = primary .. "J"
                        secondary = secondary .. "J"
                    else
                        primary = primary .. "K"
                        secondary = secondary .. "K"
                    end
                    index = index + 2
                else
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                    index = index + 2
                end
            elseif nextChar == "N" then
                if index == 1 and isVowel(getChar(2)) then
                    primary = primary .. "N"
                    secondary = secondary .. "NK"
                else
                    primary = primary .. "NK"
                    secondary = secondary .. "NK"
                end
                index = index + 1
            elseif (nextChar == "E" or nextChar == "I" or nextChar == "Y") and not matchAt(index - 1, {"A", "E", "I", "O", "U"}) then
                primary = primary .. "K"
                secondary = secondary .. "J"
                index = index + 1
            else
                if nextChar == "G" then
                    index = index + 2
                else
                    index = index + 1
                end
                primary = primary .. "K"
                secondary = secondary .. "K"
            end
        elseif char == "H" then
            if (index == 1 or isVowel(getChar(index - 1))) and isVowel(nextChar) then
                primary = primary .. "H"
                secondary = secondary .. "H"
            end
            index = index + 1
        elseif char == "J" then
            if matchAt(index, "JOSE") or (index == 1 and getChar(index + 1) == "O") then
                primary = primary .. "H"
                secondary = secondary .. "H"
            else
                primary = primary .. "J"
                secondary = secondary .. "J"
            end
            index = index + 1
        elseif char == "K" then
            if index > 1 and getChar(index - 1) == "C" then
                -- Skip
            else
                primary = primary .. "K"
                secondary = secondary .. "K"
            end
            index = index + 1
        elseif char == "L" then
            primary = primary .. "L"
            secondary = secondary .. "L"
            index = index + 1
        elseif char == "M" then
            if (index + 1 == length and getChar(index - 1) == "U" and getChar(index - 2) == "I") or matchAt(index + 1, {"E", "I"}) then
                primary = primary .. "M"
                secondary = secondary .. "M"
            else
                primary = primary .. "M"
                secondary = secondary .. "M"
            end
            index = index + 1
        elseif char == "N" then
            primary = primary .. "N"
            secondary = secondary .. "N"
            index = index + 1
        elseif char == "P" then
            if nextChar == "H" then
                primary = primary .. "F"
                secondary = secondary .. "F"
                index = index + 2
            else
                primary = primary .. "P"
                secondary = secondary .. "P"
                if nextChar == "P" then
                    index = index + 2
                else
                    index = index + 1
                end
            end
        elseif char == "Q" then
            primary = primary .. "K"
            secondary = secondary .. "K"
            if nextChar == "Q" then
                index = index + 2
            else
                index = index + 1
            end
        elseif char == "R" then
            primary = primary .. "R"
            secondary = secondary .. "R"
            index = index + 1
        elseif char == "S" then
            if matchAt(index, {"SH"}) or matchAt(index, {"SIO"}) or matchAt(index, {"SIA"}) then
                primary = primary .. "X"
                secondary = secondary .. "X"
                index = index + 2
            elseif index == 1 and matchAt(index, "SCH") then
                primary = primary .. "X"
                secondary = secondary .. "X"
                index = index + 3
            else
                primary = primary .. "S"
                secondary = secondary .. "S"
                index = index + 1
            end
        elseif char == "T" then
            if matchAt(index, {"TH"}) then
                if not (index + 2 <= length and (getChar(index + 2) == "A" or getChar(index + 2) == "U" or getChar(index + 2) == "I" or getChar(index + 2) == "E" or getChar(index + 2) == "O")) then
                    primary = primary .. "0"
                    secondary = secondary .. "T"
                else
                    primary = primary .. "0"
                    secondary = secondary .. "0"
                end
                index = index + 2
            elseif matchAt(index, {"TIO"}) or matchAt(index, {"TIA"}) then
                primary = primary .. "X"
                secondary = secondary .. "X"
                index = index + 3
            elseif matchAt(index, "TCH") or (index > 1 and matchAt(index - 1, "T") and nextChar == "Z") then
                primary = primary .. "X"
                secondary = secondary .. "X"
                index = index + 1
            else
                primary = primary .. "T"
                secondary = secondary .. "T"
                index = index + 1
            end
        elseif char == "V" then
            primary = primary .. "F"
            secondary = secondary .. "F"
            if nextChar == "V" then
                index = index + 2
            else
                index = index + 1
            end
        elseif char == "W" or char == "Y" then
            if isVowel(nextChar) then
                primary = primary .. char
                secondary = secondary .. char
            end
            index = index + 1
        elseif char == "X" then
            primary = primary .. "KS"
            secondary = secondary .. "KS"
            index = index + 1
        elseif char == "Z" then
            if nextChar == "H" then
                primary = primary .. "J"
                secondary = secondary .. "J"
                index = index + 2
            else
                primary = primary .. "S"
                secondary = secondary .. "S"
                if nextChar == "Z" then
                    index = index + 2
                else
                    index = index + 1
                end
            end
        else
            index = index + 1
        end
    end
    
    return {primary, secondary}
end

return doubleMetaphone;
