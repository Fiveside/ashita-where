---An implementation of the double metaphone algorithm in pure lua
---Based on Lawrence Philips' Double Metaphone algorithm
---@param input string The string to transform
---@return {[1]: string, [2]: string}
function doubleMetaphone(input)
    if not input or input == "" then
        return {"", ""}
    end

    local str = string.upper(input)
    local length = #str
    
    local function charAt(i)
        if i < 1 or i > length then return "\0" end
        return string.sub(str, i, i)
    end
    
    local function stringAt(i, patterns)
        if type(patterns) == "string" then patterns = {patterns} end
        for _, p in ipairs(patterns) do
            if i + #p - 1 <= length and string.sub(str, i, i + #p - 1) == p then
                return true
            end
        end
        return false
    end
    
    local function isVowel(c)
        return c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U' or c == 'Y'
    end
    
    local primary = ""
    local secondary = ""
    local i = 1
    
    -- Drop initial non-letters
    while i <= length and not string.match(charAt(i), "[A-Z]") do
        i = i + 1
    end
    
    -- Handle leading special cases
    if stringAt(i, {"GN", "KN", "WR"}) then
        i = i + 1
    end
    
    if stringAt(i, {"A", "E", "I", "O", "U", "Y"}) then
        primary = "A"
        secondary = "A"
    end
    
    -- Main loop
    while i <= length do
        local c = charAt(i)
        
        if isVowel(c) then
            if i == 1 then
                primary = primary .. "A"
                secondary = secondary .. "A"
            end
            i = i + 1
        elseif c == 'B' then
            if i == length and charAt(i - 1) == 'M' then
                -- Skip B at end after M
            else
                primary = primary .. "P"
                secondary = secondary .. "P"
            end
            if charAt(i + 1) == 'B' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'C' then
            if stringAt(i, {"CH"}) then
                if stringAt(i - 1, {"S", "T", "C"}) or (i == 1 and stringAt(i + 2, {"E", "I", "Y"})) then
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                else
                    primary = primary .. "X"
                    secondary = secondary .. "X"
                end
                i = i + 2
            elseif stringAt(i, {"CIA"}) then
                primary = primary .. "X"
                secondary = secondary .. "X"
                i = i + 3
            elseif stringAt(i, {"CZ"}) and not stringAt(i - 2, {"WI"}) then
                primary = primary .. "S"
                secondary = secondary .. "X"
                i = i + 2
            elseif stringAt(i + 1, {"E", "I", "Y"}) then
                primary = primary .. "S"
                secondary = secondary .. "S"
                i = i + 1
            else
                primary = primary .. "K"
                secondary = secondary .. "K"
                if stringAt(i + 1, {"K", "Q"}) then
                    i = i + 2
                else
                    i = i + 1
                end
            end
        elseif c == 'D' then
            if stringAt(i, {"DG"}) and stringAt(i + 2, {"E", "I", "Y"}) then
                primary = primary .. "J"
                secondary = secondary .. "J"
                i = i + 3
            else
                primary = primary .. "T"
                secondary = secondary .. "T"
                i = i + 1
            end
        elseif c == 'G' then
            if charAt(i + 1) == 'H' then
                if i == length or (i + 1 == length) then
                    -- GH at end
                    if i > 1 and not isVowel(charAt(i - 1)) then
                        primary = primary .. "K"
                        secondary = secondary .. "K"
                    end
                    i = i + 2
                elseif i > 1 and not isVowel(charAt(i - 1)) then
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                    i = i + 2
                elseif i == 1 and charAt(i + 2) == 'I' then
                    primary = primary .. "J"
                    secondary = secondary .. "J"
                    i = i + 2
                else
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                    i = i + 2
                end
            elseif charAt(i + 1) == 'N' then
                if i == 1 and isVowel(charAt(2)) then
                    primary = primary .. "N"
                    secondary = secondary .. "NK"
                else
                    primary = primary .. "NK"
                    secondary = secondary .. "NK"
                end
                i = i + 1
            elseif stringAt(i + 1, {"E", "I", "Y"}) then
                primary = primary .. "K"
                secondary = secondary .. "J"
                i = i + 1
            else
                primary = primary .. "K"
                secondary = secondary .. "K"
                if charAt(i + 1) == 'G' then
                    i = i + 2
                else
                    i = i + 1
                end
            end
        elseif c == 'H' then
            if (i == 1 or isVowel(charAt(i - 1))) and isVowel(charAt(i + 1)) then
                primary = primary .. "H"
                secondary = secondary .. "H"
            end
            i = i + 1
        elseif c == 'J' then
            if stringAt(i, {"JOSE"}) or (i == 1 and charAt(i + 1) == 'O') then
                primary = primary .. "H"
                secondary = secondary .. "H"
            else
                primary = primary .. "J"
                secondary = secondary .. "J"
            end
            if charAt(i + 1) == 'J' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'K' then
            if charAt(i - 1) ~= 'C' then
                primary = primary .. "K"
                secondary = secondary .. "K"
            end
            if charAt(i + 1) == 'K' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'L' then
            primary = primary .. "L"
            secondary = secondary .. "L"
            if charAt(i + 1) == 'L' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'M' then
            primary = primary .. "M"
            secondary = secondary .. "M"
            if charAt(i + 1) == 'M' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'N' then
            primary = primary .. "N"
            secondary = secondary .. "N"
            if charAt(i + 1) == 'N' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'P' then
            if charAt(i + 1) == 'H' then
                primary = primary .. "F"
                secondary = secondary .. "F"
                i = i + 2
            else
                primary = primary .. "P"
                secondary = secondary .. "P"
                if charAt(i + 1) == 'P' then
                    i = i + 2
                else
                    i = i + 1
                end
            end
        elseif c == 'Q' then
            primary = primary .. "K"
            secondary = secondary .. "K"
            if charAt(i + 1) == 'Q' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'R' then
            primary = primary .. "R"
            secondary = secondary .. "R"
            if charAt(i + 1) == 'R' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'S' then
            if stringAt(i, {"SH"}) then
                primary = primary .. "X"
                secondary = secondary .. "X"
                i = i + 2
            elseif stringAt(i, {"SIO", "SIA"}) then
                primary = primary .. "X"
                secondary = secondary .. "X"
                i = i + 3
            else
                primary = primary .. "S"
                secondary = secondary .. "S"
                if charAt(i + 1) == 'S' then
                    i = i + 2
                else
                    i = i + 1
                end
            end
        elseif c == 'T' then
            if stringAt(i, {"TH"}) then
                if i + 2 <= length and stringAt(i + 2, {"A", "E", "I", "O", "U"}) then
                    primary = primary .. "0"
                    secondary = secondary .. "0"
                else
                    primary = primary .. "0"
                    secondary = secondary .. "T"
                end
                i = i + 2
            elseif stringAt(i, {"TIO", "TIA"}) then
                primary = primary .. "X"
                secondary = secondary .. "X"
                i = i + 3
            elseif stringAt(i, {"TCH"}) then
                primary = primary .. "X"
                secondary = secondary .. "X"
                i = i + 3
            else
                primary = primary .. "T"
                secondary = secondary .. "T"
                if charAt(i + 1) == 'T' then
                    i = i + 2
                else
                    i = i + 1
                end
            end
        elseif c == 'V' then
            primary = primary .. "F"
            secondary = secondary .. "F"
            if charAt(i + 1) == 'V' then
                i = i + 2
            else
                i = i + 1
            end
        elseif c == 'W' then
            if isVowel(charAt(i + 1)) then
                primary = primary .. "W"
                secondary = secondary .. "W"
            end
            i = i + 1
        elseif c == 'X' then
            primary = primary .. "KS"
            secondary = secondary .. "KS"
            i = i + 1
        elseif c == 'Y' then
            if isVowel(charAt(i + 1)) then
                primary = primary .. "Y"
                secondary = secondary .. "Y"
            end
            i = i + 1
        elseif c == 'Z' then
            primary = primary .. "S"
            secondary = secondary .. "S"
            if charAt(i + 1) == 'Z' then
                i = i + 2
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end
    
    return {primary, secondary}
end

return doubleMetaphone;
