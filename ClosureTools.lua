local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/LuaMadness/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Closure tools",
    IntroEnabled = true,
    IntroText = 'by LuaMadness',
})
local dropdown

local searchText = 'Fire'
local searchMode = 'Function Name'

local Search = Window:MakeTab({Name = 'Search'})
local Info = Window:MakeTab({Name = 'Info'})

local results = {}
local function search()

    print(searchText, searchMode)

    results = {}
    if searchMode == 'Function Name' then
        for _, func in pairs(getgc()) do
            if typeof(func) == 'function' then
                local info = debug.getinfo(func)
                if info and info.name and info.source then
                    if string.find(info.name, searchText) then
                        table.insert(results, func)
                    end
                end
            end
        end
    elseif searchMode == "Script Name" then
        for _, func in pairs(getgc()) do
            if typeof(func) == 'function' then
                local info = debug.getinfo(func)
                if info and info.name and info.source then
                    if string.find(info.source, searchText) then
                        table.insert(results, func)
                    end
                end
            end
        end
    end
    for i, v in results do
        local formatted = {}
        for i, v in results do
            local info = debug.getinfo(v)
            table.insert(formatted, i..'| '..info.name..' @ '..string.sub(info.source, 2, #info.source))
        end
        dropdown:Refresh(formatted, true)
    end
end
local showResults

local currFunc
local upValuesFormatted = {}

Search:AddTextbox({
    Name = 'Search',
    Default = 'Fire',
    Callback = function(Text)
        searchText = Text
    end
})
Search:AddDropdown({
    Name = "Search Mode",
    Options = {"Function Name","Script Name"},
    Default = 'Function Name',
    Callback = function(Option)
        searchMode = Option
    end
})
Search:AddButton({
    Name = 'Search',
    Callback = search
})
dropdown = Search:AddDropdown({
    Name = 'Results',
    Options = {'Your results will appear here'},
    Default = 'Your results will appear here',
    Callback = function(Option)
        local id = tonumber(string.split(Option, '|')[1])
        local func = results[id]
        if func then
            print(showResults)
            showResults(func)
        end
    end
})

local closureInfo = Info:AddParagraph('Closure Information', '-')

local function formatRes(tbl)
    local str = ''
    for i, v in tbl do
        str ..= tostring(i) .. ': '.. tostring(v) ..'\n'
    end
    return string.sub(str, 1, #str - 1)
end

local chosenUpvalueId = 0
upvalueList = Info:AddDropdown({
    Name = 'Upvalue List',
    Options = {'Upvalues will appear here'},
    Default = 'Upvalues will appear here',
    Callback = function(Option)
        if currFunc then
            local id = tonumber(string.split(Option, '|')[1])
            chosenUpvalueId = id
        end
    end
})

upvalueEditor = Info:AddTextbox({
    Name = 'Upvalue Editor',
    Default = 'Enter new value',
    Callback = function(Text)
        if not currFunc or not chosenUpvalueId then return end
        local upvalue = debug.getupvalue(currFunc, chosenUpvalueId)
        local valType = typeof(upvalue)
        if valType == 'string' then
            debug.setupvalue(currFunc, chosenUpvalueId, Text)
        elseif valType == 'number' then
            debug.setupvalue(currFunc, chosenUpvalueId, tonumber(Text))
        elseif valType == 'boolean' then
            debug.setupvalue(currFunc, chosenUpvalueId, Text == 'true')
        end
        print(debug.getupvalue(currFunc, chosenUpvalueId))
    end
})

showResults = function(func)
    currFunc = func
    local info = debug.getinfo(func)

    closureInfo:Set(formatRes({
        name = info.name,
        type = info.what,
        source = string.sub(info.source, 2, #info.source),
        upvalues = info.nups,
        numparams = info.numparams,
        currentline = info.currentline
    }))

    upValuesFormatted = {}
    for i, v in debug.getupvalues(func) do
        table.insert(upValuesFormatted, i..'| ' .. tostring(v) .. ' (' .. typeof(v) ..')') 
    end
    upvalueList:Refresh(upValuesFormatted, true)
end
