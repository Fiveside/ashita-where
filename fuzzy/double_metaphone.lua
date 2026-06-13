
---An implementation of the double metaphone algorithm in pure lua
---Based on Lawrence Philips' Double Metaphone algorithm
---@param input string The string to transform
---@return {[1]: string, [2]: string}
function doubleMetaphone(input)
    if not input or input == "" then
        return {"", ""}
    end

    -- Convert to uppercase
    local str = string.upper(input)
    local length = #str
    
    -- Helper to check character at index
    local function charAt(i)
        if i < 1 or i > length then return "\0" end
        return string.sub(str, i, i)
    end
    
    -- Helper to check for match at position
    local function stringAt(i, patterns)
        if type(patterns) == "string" then patterns = {patterns} end
        for _, p in ipairs(patterns) do
            if i + #p - 1 <= length and string.sub(str, i, i + #p - 1) == p then
                return true
            end
        end
        return false
    end
    
    -- Helper to check if character is vowel
    local function isVowel(c)
        return c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U' or c == 'Y'
    end
    
    local primary = ""
    local secondary = ""
    local i = 1
    
    -- Handle leading non-letters
    if stringAt(1, {"GN"}) or stringAt(1, {"KN"}) or stringAt(1, {"WR"}) then
        i = 2
    end
    
    -- Handle special initial letters
    if stringAt(1, {"A", "E", "I", "O", "U", "Y"}) then
        primary = "A"
        secondary = "A"
        i = 2
    end
    
    -- Main encoding loop
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
                -- Skip final B after M
            else
                primary = primary .. "P"
                secondary = secondary .. "P"
            end
            i = i + (charAt(i + 1) == 'B' and 2 or 1)
        elseif c == 'C' then
            if stringAt(i, {"CH"}) then
                if not stringAt(i - 1, {"S", "T", "C"}) and (i == 1 or not stringAt(i - 2, {"T", "D"})) then
                    primary = primary .. "X"
                    secondary = secondary .. "X"
                else
                    primary = primary .. "K"
                    secondary = secondary .. "K"
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
                if i > 1 and not isVowel(charAt(i - 1)) then
                    primary = primary .. "K"
                    secondary = secondary .. "K"
                    i = i + 2
                elseif i == 1 then
                    if charAt(i + 2) == 'I' then
                        primary = primary .. "J"
                        secondary = secondary .. "J"
                    else
                        primary = primary .. "K"
                        secondary = secondary .. "K"
                    end
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
            elseif stringAt(i + 1, {"E", "I", "Y"}) and not stringAt(i - 1, {"D", "T"}) then
                primary = primary .. "J"
                secondary = secondary .. "K"
                i = i + 1
            else
                primary = primary .. "K"
                secondary = secondary .. "K"
                i = i + (charAt(i + 1) == 'G' and 2 or 1)
            end
        elseif c == 'H' then
            if (i == 1 or isVowel(charAt(i - 1))) and isVowel(charAt(i + 1)) then
                primary = primary .. "H"
                secondary = secondary .. "H"
            end
            i = i + 1
        elseif c == 'J' then
            primary = primary .. "J"
            secondary = secondary .. "J"
            i = i + 1
        elseif c == 'K' then
            if charAt(i - 1) ~= 'C' then
                primary = primary .. "K"
                secondary = secondary .. "K"
            end
            i = i + 1
        elseif c == 'L' then
            primary = primary .. "L"
            secondary = secondary .. "L"
            i = i + 1
        elseif c == 'M' then
            primary = primary .. "M"
            secondary = secondary .. "M"
            i = i + 1
        elseif c == 'N' then
            primary = primary .. "N"
            secondary = secondary .. "N"
            i = i + 1
        elseif c == 'P' then
            if charAt(i + 1) == 'H' then
                primary = primary .. "F"
                secondary = secondary .. "F"
                i = i + 2
            else
                primary = primary .. "P"
                secondary = secondary .. "P"
                i = i + (charAt(i + 1) == 'P' and 2 or 1)
            end
        elseif c == 'Q' then
            primary = primary .. "K"
            secondary = secondary .. "K"
            i = i + 1
        elseif c == 'R' then
            primary = primary .. "R"
            secondary = secondary .. "R"
            i = i + 1
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
                i = i + (charAt(i + 1) == 'S' and 2 or 1)
            end
        elseif c == 'T' then
            if stringAt(i, {"TH"}) then
                if i + 2 <= length and not stringAt(i + 2, {"A", "E", "I", "O", "U"}) then
                    primary = primary .. "0"
                    secondary = secondary .. "T"
                else
                    primary = primary .. "0"
                    secondary = secondary .. "0"
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
                i = i + (charAt(i + 1) == 'T' and 2 or 1)
            end
        elseif c == 'V' then
            primary = primary .. "F"
            secondary = secondary .. "F"
            i = i + 1
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
            i = i + 1
        else
            i = i + 1
        end
    end
    
    return {primary, secondary}
end

return doubleMetaphone;
