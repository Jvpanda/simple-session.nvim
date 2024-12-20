local function getCurrentIncrementValue(filePath, incrementAmount, filetype)
    local i = 0
    local pathTrimmed = filePath:match("^(.*_)")
    while i < 100 do
        if vim.fn.filereadable(pathTrimmed .. i .. filetype) == 0 then
            -- base case if a file doesn't exist
            if i == 0 then
                return pathTrimmed .. i .. filetype
            end
            return pathTrimmed .. i - 1 + incrementAmount .. filetype
        end
        i = i + 1
    end
    return filePath .. "_error"
end

local function delAllMarks()
    local bufs = vim.api.nvim_list_bufs()
    for key in ipairs(bufs) do
        if vim.fn.buflisted(bufs[key]) == 1 then
            local n = 0
            while n <= 25 do
                vim.api.nvim_buf_del_mark(bufs[key], string.char(97 + n))
                n = n + 1
            end
        end
    end
end

M.overwriteSession = function(sessionDir)
    local savePath = sessionDir .. vim.fn.expand("%:p:h:t") .. "_0.vim"
    local shadaSavePath = sessionDir .. "shada/" .. vim.fn.expand("%:p:h:t") .. "_0.shada"

    -- If there is no session we use the dir name as the session name
    -- If a dir name exists, we will find the latest increment of it and overwrite that
    -- Otherwise we just overwrite the current session
    if M._currentSesh == "/noSelectedSession." then
        savePath = getCurrentIncrementValue(savePath, 0, ".vim")
        shadaSavePath = getCurrentIncrementValue(shadaSavePath, 0, ".shada")
    else
        savePath = M._currentSesh
        shadaSavePath = sessionDir .. "shada/" .. M._currentSesh:gsub("^(.*[/\\])", 0):sub(2, -5) .. ".shada"
    end

    vim.cmd.wall()
    M.writeShada(shadaSavePath)
    vim.cmd({ cmd = "mksession", args = { savePath }, bang = true })
    M._currentSesh = savePath
    print("save path: " .. savePath)
end

M.makeUniqueSession = function(sessionDir)
    local savePath = sessionDir .. vim.fn.expand("%:p:h:t") .. "_0.vim"
    local shadaSavePath = sessionDir .. "shada/" .. vim.fn.expand("%:p:h:t") .. "_0.shada"
    local nameInput = ""
    local inSession = false
    print(savePath)

    nameInput =
        vim.fn.input({ cancelreturn = "abort", prompt = "Type a unique name or no name to save incrementally: " })

    if M._currentSesh == "/noSelectedSession." then
        inSession = false
    else
        inSession = true
    end

    if nameInput == "" and inSession == false then
        savePath = getCurrentIncrementValue(savePath, 1, ".vim")
        shadaSavePath = getCurrentIncrementValue(shadaSavePath, 1, ".shada")
    elseif nameInput == "" and inSession == true then
        savePath = getCurrentIncrementValue(M._currentSesh, 1, ".vim")
        shadaSavePath = getCurrentIncrementValue(
            sessionDir .. "shada/" .. M._currentSesh:gsub("^(.*[/\\])", "") .. ".shada",
            1,
            ".shada"
        )
    else
        savePath = getCurrentIncrementValue(sessionDir .. nameInput .. "_0.vim", 1, ".vim")
        shadaSavePath = getCurrentIncrementValue(sessionDir .. "shada/" .. nameInput .. "_0.shada", 1, ".shada")
    end

    vim.cmd.wall()
    M.writeShada(shadaSavePath)
    vim.cmd({ cmd = "mksession", args = { savePath }, bang = true })
    M._currentSesh = savePath
    print("save path: " .. savePath)
end

M.writeShada = function(filePath)
    local shadaSettings = vim.fn.execute("set shada"):sub(10, -1)
    vim.cmd.set("shada ='1000,f1,<0,:0,@0,%0,/0,r0,h")
    vim.cmd({ cmd = "wsh", args = { filePath }, bang = true })
    vim.cmd({ cmd = "set", args = { "shada=" .. shadaSettings } })
end

M.readShada = function(filePath)
    delAllMarks()
    vim.cmd("delmarks A-Z0-9")
    vim.cmd({ cmd = "rshada", args = { filePath }, bang = true })
end

return M
