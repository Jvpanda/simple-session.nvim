local selectedUISessionDir = "nil"

local function editStatusLine()
    local currentSeshStripped = M._currentSesh:gsub("^(.*[/\\])", "")
    local directory = M.getSessionDir():sub(1, -2):gsub("^(.*[/\\])", "")
    vim.opt.statusline = "File: " .. "%t" .. " | Session: " .. directory .. "/" .. currentSeshStripped
end

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

local function setUIKeymaps(sessionDir)
    vim.keymap.set("n", "<esc>", function()
        deleteCurrentWindow()
    end, { buffer = true })

    vim.keymap.set("n", "D", function()
        local selectedDir = sessionDir .. vim.fn.getline(".") .. ".vim"
        if vim.fn.filereadable(selectedDir) == 1 then
            vim.fn.delete(selectedDir)
            vim.fn.delete(sessionDir .. "shada/" .. vim.fn.getline(".") .. ".shada")
            vim.api.nvim_del_current_line()
        else
            print("Not a valid file")
        end
    end, { buffer = true })

    vim.keymap.set("n", "<CR>", function()
        local selectedDir = sessionDir .. vim.fn.getline(".") .. ".vim"
        if vim.fn.filereadable(selectedDir) == 1 then
            M._currentSesh = selectedDir
            M.setSessionDir(sessionDir)
            vim.cmd.q()
            deleteBuffers(getBuffersForDelete())
            vim.cmd.source(selectedDir)
            editStatusLine()
        elseif vim.fn.getline(".") == "----Press Enter Here To Change Dir----" then
            M._currentSesh = "/noSelectedSession."
            M.setSessionDir(selectedUISessionDir)
            deleteCurrentWindow()
            print("Session Directory has been set to: " .. selectedUISessionDir)
            editStatusLine()
        else
            print("Not a valid file")
        end
    end, { buffer = true })

    vim.keymap.set("n", "U", function()
        local buf = vim.fn.bufnr()
        vim.cmd.q()
        vim.api.nvim_buf_delete(buf, {})
        local sessionStripped = sessionDir:match("^(.*[/\\])"):sub(1, -2):match("^(.*[/\\])"):sub(1, -2)
        M.openSessionDirectoriesList(sessionStripped)
    end, { buffer = true })
end

local function setDirectoryListUIKeymaps(sessionDir)
    vim.keymap.set("n", "Y", function()
        local selectedDir = sessionDir .. "/" .. vim.fn.getline(".") .. "/"
        if vim.fn.isdirectory(selectedDir) == 1 then
            M._currentSesh = "/noSelectedSession."
            M.setSessionDir(selectedDir)
            vim.api.nvim_buf_set_lines(0, 2, 3, false, { "Current Directory: " .. vim.fn.getline(".") })
        else
            print("Not a valid Directory")
        end
    end, { buffer = true })

    vim.keymap.set("n", "<esc>", function()
        deleteCurrentWindow()
    end, { buffer = true })

    vim.keymap.set("n", "D", function()
        local selectedDir = sessionDir .. "/" .. vim.fn.getline(".")
        if vim.fn.isdirectory(selectedDir) == 1 then
            vim.fn.delete(selectedDir, "rf")
            vim.api.nvim_del_current_line()
        else
            print("Not a valid file")
        end
    end, { buffer = true })

    vim.keymap.set("n", "<CR>", function()
        local selectedDir = sessionDir .. "/" .. vim.fn.getline(".") .. "/"
        if vim.fn.isdirectory(selectedDir) == 1 then
            deleteCurrentWindow()
            M.openSessionList(selectedDir, "----Press Enter Here To Change Dir----")
            selectedUISessionDir = selectedDir
            print(selectedUISessionDir)
        else
            print("Not a valid directory")
        end
    end, { buffer = true })

    vim.keymap.set("n", "A", function()
        local newDirInput = vim.fn.input({ cancelreturn = "none", prompt = "Please input a dir name: " })
        local newDir = sessionDir .. "/" .. newDirInput
        addSessionDirectory(newDir)
        vim.api.nvim_buf_set_lines(0, -1, -1, false, { newDirInput })
    end, { buffer = true })
end

M.openSessionList = function(sessionDir, instructionsParam)
    instructionsParam = instructionsParam or "---------------"
    local fileList = vim.fn.globpath(vim.fn.expand(sessionDir), "*.vim", false, true)
    local currentSeshStripped = M._currentSesh:gsub("^(.*[/\\])", "")
    local directory = M.getSessionDir():sub(1, -2):gsub("^(.*[/\\])", "")
    if M._currentSesh == "/noSelectedSession." then
        directory = ""
        currentSeshStripped = "No Selected Session"
    end

    local instructions = {
        "Enter to select, Esc to exit, D to delete",
        "U to view Directories",
        "Current Session: " .. directory .. "/" .. currentSeshStripped,
        instructionsParam,
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

    setUIKeymaps(sessionDir)
end

M.openSessionDirectoriesList = function(sessionDir)
    local fileList = vim.fn.globpath(sessionDir, "*", false, true)
    local currentDirectory = M.getSessionDir():sub(1, -2):gsub("^(.*[/\\])", "")

    local instructions = {
        "Enter to select, Esc to exit",
        "D to delete, A to add, Y to select directory",
        "Current Directory: " .. currentDirectory,
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

    setDirectoryListUIKeymaps(sessionDir)
end

return M
