local M = {}
M.sessionRoot = vim.fn.expand("~/nvim_sessions/") --The root
M.currentSessionDirectoryPath = M.sessionRoot .. "Default/"
M.currentSessionName = "/none/"

M.setupRootDirectory = function()
    if vim.fn.isdirectory(M.sessionRoot) == false then
        vim.fn.mkdir(M.sessionRoot, "p")
    end
    if vim.fn.isdirectory(M.currentSessionDirectoryPath) == 0 then
        vim.fn.mkdir(M.currentSessionDirectoryPath, "p")
    end
    if vim.fn.isdirectory(M.currentSessionDirectoryPath .. "shada/") == 0 then
        vim.fn.mkdir(M.currentSessionDirectoryPath .. "shada/", "p")
    end
end

M.isSessionSelected = function()
    if M.currentSessionName == "/none/" then
        return false
    else
        return true
    end
end

M.getSavePathIncrementValue = function()
    local path = M.currentSessionDirectoryPath .. M.currentSessionName:match("^(.*[_])", 1):sub(1, -2) .. "_"
    local i = 0
    while i < 100 do
        if vim.fn.filereadable(path .. i .. ".vim") == 0 then
            -- base case if a file doesn't exist
            if i == 0 then
                return 0
            else
                return i - 1
            end
        end
        i = i + 1
    end
end

M.getFullSessionPath = function(increment)
    increment = increment or 0
    return M.currentSessionDirectoryPath
        .. M.currentSessionName:match("^(.*[_])", 1):sub(1, -2)
        .. "_"
        .. M.getSavePathIncrementValue() + increment
        .. ".vim"
end

M.getFullShadaPath = function(increment)
    increment = increment or 0
    return M.currentSessionDirectoryPath
        .. "shada/"
        .. M.currentSessionName:match("^(.*[_])", 1):sub(1, -2)
        .. "_"
        .. M.getSavePathIncrementValue() + increment
        .. ".shada"
end

--[[
M.currentSessionDirectoryPath = vim.fn.expand("%:p:h") .. "/"
M.currentSessionName = "Gay"
print(M.currentSessionDirectoryPath)
print(M.currentSessionName)
print("Modified Name: " .. vim.fn.fnamemodify(M.currentSessionDirectoryPath, ":h:t"))

print("Inc Value: " .. M.getSavePathIncrementValue())
print(M.getFullSessionPath())
print(M.getFullShadaPath())
]]

return M
