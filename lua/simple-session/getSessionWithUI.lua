local M = {}
local SDM = require("simple-session.sessionDirectoryManager")
local readWrite = require("simple-session.readWrite")
local rootDirectorySelection = "nil"

--[[General Functions]]
local function deleteCurrentWindow()
    local buf = vim.fn.bufnr()
    vim.cmd.q()
    vim.api.nvim_buf_delete(buf, {})
end

local function getBuffersForDelete()
    local buffersForDelete = {}
    local bufsList = vim.api.nvim_list_bufs()
    local i = 1
    for key in ipairs(bufsList) do
        if vim.fn.buflisted(bufsList[key]) == 1 then
            buffersForDelete[i] = bufsList[key]
            i = i + 1
        end
    end
    return buffersForDelete
end

local function deleteBuffers(bufs)
    vim.cmd.wall()
    for key in ipairs(bufs) do
        vim.api.nvim_buf_delete(bufs[key], {})
    end
end

local function addSessionDirectory(dir)
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
    if vim.fn.isdirectory(dir .. "/shada/") == 0 then
        vim.fn.mkdir(dir .. "/shada/")
    end
end

-- [[Session list]]
local function setSessionListUIKeymaps()
    vim.keymap.set("n", "<esc>", function()
        local buf = vim.fn.bufnr()
        vim.cmd.q()
        vim.api.nvim_buf_delete(buf, {})
        M.openSessionRootDirectoriesUI()
    end, { buffer = true })

    vim.keymap.set("n", "D", function()
        local selectedSession = rootDirectorySelection .. vim.fn.getline(".") .. ".vim"
        print(selectedSession)
        if vim.fn.filereadable(selectedSession) == 1 then
            vim.fn.delete(selectedSession)
            vim.fn.delete(SDM.currentSessionDirectoryPath .. "shada/" .. vim.fn.getline(".") .. ".shada")
            vim.api.nvim_del_current_line()
        else
            print("Not a valid file")
        end
    end, { buffer = true })

    vim.keymap.set("n", "<CR>", function()
        local sessionPath = ""
        local shadaPath = ""
        if rootDirectorySelection == SDM.currentSessionDirectoryPath then
            sessionPath = SDM.currentSessionDirectoryPath .. vim.fn.getline(".") .. ".vim"
            shadaPath = SDM.currentSessionDirectoryPath .. "shada/" .. vim.fn.getline(".") .. ".shada"
        else
            sessionPath = rootDirectorySelection .. vim.fn.getline(".") .. ".vim"
            shadaPath = rootDirectorySelection .. "shada/" .. vim.fn.getline(".") .. ".shada"
        end

        if vim.fn.filereadable(sessionPath) == 1 then
            SDM.currentSessionDirectoryPath = rootDirectorySelection
            SDM.currentSessionName = vim.fn.getline(".")
            vim.cmd.q()
            deleteBuffers(getBuffersForDelete())
            vim.cmd.source(sessionPath)
            readWrite.readShada(shadaPath)
        elseif vim.fn.getline(".") == "----Press Enter Here To Select Dir----" then
            SDM.currentSessionName = "/none/"
            SDM.currentSessionDirectoryPath = rootDirectorySelection
            deleteCurrentWindow()
            print("Session Directory has been set to: " .. rootDirectorySelection)
        else
            print("Not a valid file")
        end
    end, { buffer = true })
end

M.openSessionListUI = function(fromMainMenu)
    local fromMenu = fromMainMenu or false
    local path = ""
    if fromMenu == true then
        path = rootDirectorySelection
    else
        path = SDM.currentSessionDirectoryPath
    end

    local fileList = vim.fn.globpath(path, "*.vim", false, true)

    local instructions = {
        "Enter to select, D to delete",
        "Esc to go back to the directory",
        "Current Session: " .. SDM.currentSessionName,
        "----Press Enter Here To Select Dir----",
    }
    for key in ipairs(fileList) do
        fileList[key] = fileList[key]:gsub("^(.*[/\\])", ""):match("^(.*[.])"):sub(1, -2)
    end

    -- Calculate window size
    local win_width = 50
    local win_height = #fileList + 7

    -- Create a floating window
    local opts = {
        relative = "editor", -- Relative to the editor
        width = win_width,
        height = win_height,
        col = (vim.o.columns - win_width) / 2,
        row = (vim.o.lines - win_height) / 2,
        style = "minimal",
        border = "rounded", -- You can also use 'single', 'double', 'solid', etc.
    }

    -- Create the floating window
    local buf = vim.api.nvim_create_buf(true, true) -- Create a new buffer
    vim.api.nvim_open_win(buf, true, opts) -- Open the window

    -- Set buffer content (list of files)
    vim.api.nvim_buf_set_lines(buf, 0, 4, false, instructions)
    vim.api.nvim_buf_set_lines(buf, 4, -1, false, fileList)
    vim.fn.cursor(4, 1)

    setSessionListUIKeymaps()
end

-- [[Root Directory Setup]]
local function setRootDirectoriesUIKeymaps()
    vim.keymap.set("n", "<esc>", function()
        deleteCurrentWindow()
    end, { buffer = true })

    vim.keymap.set("n", "Y", function()
        local tempCheck = SDM.sessionRoot .. vim.fn.getline(".") .. "/"
        print(tempCheck)
        if vim.fn.isdirectory(tempCheck) == 1 then
            SDM.currentSessionDirectoryPath = tempCheck
            SDM.currentSessionName = "/none/"
            vim.api.nvim_buf_set_lines(0, 2, 3, false, { "Current Directory: " .. vim.fn.getline(".") })
        else
            print("Not a valid Directory")
        end
    end, { buffer = true })

    vim.keymap.set("n", "D", function()
        local tempCheck = SDM.sessionRoot .. vim.fn.getline(".") .. "/"
        if vim.fn.isdirectory(tempCheck) == 1 then
            vim.fn.delete(tempCheck, "rf")
            vim.api.nvim_del_current_line()
        else
            print("Not a valid Directory")
        end
    end, { buffer = true })

    --Need to refine this one still
    vim.keymap.set("n", "<CR>", function()
        local tempCheck = SDM.sessionRoot .. vim.fn.getline(".") .. "/"
        if vim.fn.isdirectory(tempCheck) == 1 then
            rootDirectorySelection = tempCheck
            deleteCurrentWindow()
            M.openSessionListUI(true)
        else
            print("Not a valid Directory")
        end
    end, { buffer = true })

    vim.keymap.set("n", "A", function()
        local newDirInput = vim.fn.input({ cancelreturn = "none", prompt = "Please input a dir name: " })
        local newDir = SDM.sessionRoot .. newDirInput
        addSessionDirectory(newDir)
        vim.api.nvim_buf_set_lines(0, -1, -1, false, { newDirInput })
    end, { buffer = true })
end

M.openSessionRootDirectoriesUI = function()
    local fileList = vim.fn.globpath(SDM.sessionRoot, "*", false, true)

    local instructions = {
        "Enter to select, Esc to exit",
        "D to delete, A to add, Y to select directory",
        "Current Directory: " .. vim.fn.fnamemodify(SDM.currentSessionDirectoryPath, ":h:t"),
        "---------------",
    }

    for key in ipairs(fileList) do
        fileList[key] = fileList[key]:gsub("^(.*[/\\])", "")
    end

    -- Calculate window size
    local win_width = 50
    local win_height = #fileList + 7

    -- Create a floating window
    local opts = {
        relative = "editor", -- Relative to the editor
        width = win_width,
        height = win_height,
        col = (vim.o.columns - win_width) / 2,
        row = (vim.o.lines - win_height) / 2,
        style = "minimal",
        border = "rounded", -- You can also use 'single', 'double', 'solid', etc.
    }

    -- Create the floating window
    local buf = vim.api.nvim_create_buf(true, true) -- Create a new buffer
    vim.api.nvim_open_win(buf, true, opts) -- Open the window

    -- Set buffer content (list of files)
    vim.api.nvim_buf_set_lines(buf, 0, 4, false, instructions)
    vim.api.nvim_buf_set_lines(buf, 4, -1, false, fileList)
    vim.fn.cursor(5, 1)
    setRootDirectoriesUIKeymaps()
end

return M
