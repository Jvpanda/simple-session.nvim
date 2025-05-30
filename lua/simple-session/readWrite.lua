local M = {}
local SDM = require("simple-session.sessionDirectoryManager")

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

M.overwriteSession = function()
    -- If there is no session we use the dir name as the session name
    -- If a dir name exists, we will find the latest increment of it and overwrite that
    if SDM.isSessionSelected() == false then
        SDM.currentSessionName = vim.fn.expand("%:p:h:t")
    end

    vim.cmd.wall()
    M.writeShada(SDM.getFullShadaPath())
    vim.cmd({ cmd = "mksession", args = { SDM.getFullSessionPath() }, bang = true })
    print("Save Path: " .. SDM.getFullSessionPath())
end

M.makeUniqueSession = function()
    local increment = 0
    local nameInput =
        vim.fn.input({ cancelreturn = "abort", prompt = "Type a unique name or no name to save incrementally: " })

    if nameInput == "abort" then
        print("No session created")
        return
    end

    nameInput = nameInput .. "_0.pp"

    if nameInput == "_0.pp" and SDM.isSessionSelected() == false then
        SDM.currentSessionName = vim.fn.expand("%:p:h:t") .. nameInput
    elseif nameInput == "_0.pp" and SDM.isSessionSelected() == true then
        increment = 1
    else
        SDM.currentSessionName = nameInput
    end

    vim.cmd.wall()
    M.writeShada(SDM.getFullShadaPath(increment))
    vim.cmd({ cmd = "mksession", args = { SDM.getFullSessionPath(increment) }, bang = true })
    SDM.currentSessionName = SDM.currentSessionName:match("^(.*[_])", 1):sub(1, -2)
        .. "_"
        .. SDM.getSavePathIncrementValue()
    print("Save Path: " .. SDM.getFullSessionPath(0))
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
