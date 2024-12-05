M = {}

M._currentSesh = "noSelectedSession"

local sessionDir = vim.fn.expand("~/nvim_sessions/")

M.setup = function(opts)
    opts = opts or {}

    vim.keymap.set("n", "<leader>as", function()
        M.overwriteSession()
    end, { desc = "Save regular session" })
    vim.keymap.set("n", "<leader>au", function()
        M.makeUniqueSession()
    end, { desc = "Create unique session" })
    vim.keymap.set("n", "<leader>aa", function()
        M.getSession()
    end, { desc = "Choose a session to return to" })
    vim.keymap.set("n", "<leader>a", "", { desc = "Simple Session" })

    if opts.session_directory then
        sessionDir = opts.session_directory
    else
        sessionDir = vim.fn.expand("~/nvim_sessions/")
    end

    if vim.fn.isdirectory(sessionDir) == 0 then
        print("created dir")
        vim.fn.mkdir(vim.fn.expand(sessionDir), "p")
    end
end

local function getCurrentIncrementValue(sessionFilePath, incrementAmount)
    local i = 0
    local pathTrimmed = sessionFilePath:match("^(.*_)")
    while i < 100 do
        if vim.fn.filereadable(pathTrimmed .. i .. ".vim") == 0 then
            -- base case if a file doesn't exist
            if i == 0 then
                return pathTrimmed .. i .. ".vim"
            end
            return pathTrimmed .. i - 1 + incrementAmount .. ".vim"
        end
        i = i + 1
    end
    return sessionFilePath .. "_error"
end

M.overwriteSession = function()
    local savePath = sessionDir .. vim.fn.expand("%:p:h:t") .. "_0.vim"

    -- If there is no session we use the dir name as the session name
    -- If a dir name exists, we will find the latest increment of it and overwrite that
    -- Otherwise we just overwrite the current session
    if M._currentSesh == "noSelectedSession" then
        savePath = getCurrentIncrementValue(savePath, 0)
    else
        savePath = M._currentSesh
    end

    vim.cmd.wall()
    vim.cmd({ cmd = "mksession", args = { savePath }, bang = true })
    M._currentSesh = savePath
    print("save path: " .. savePath .. " | currentSesh: " .. M._currentSesh)
end

M.makeUniqueSession = function()
    local savePath = sessionDir .. vim.fn.expand("%:p:h:t") .. "_0.vim"
    local nameInput = ""
    local inSession = false

    nameInput =
        vim.fn.input({ cancelreturn = "abort", prompt = "Type a unique name or no name to save incrementally: " })

    if M._currentSesh == "noSelectedSession" then
        inSession = false
    else
        inSession = true
    end

    if nameInput == "" and inSession == false then
        savePath = getCurrentIncrementValue(savePath, 1)
    elseif nameInput == "" and inSession == true then
        savePath = getCurrentIncrementValue(M._currentSesh, 1)
    else
        savePath = getCurrentIncrementValue(sessionDir .. nameInput .. "_0.vim", 1)
    end

    vim.cmd.wall()
    vim.cmd({ cmd = "mksession", args = { savePath }, bang = true })
    M._currentSesh = savePath
    print("save path: " .. savePath .. " | currentSesh: " .. M._currentSesh)
end

M.getSession = function()
    vim.cmd.e(sessionDir)
    local tmpBuffer = vim.fn.bufnr(0)

    vim.keymap.del("n", "<CR>", { buffer = true })
    vim.keymap.set("n", "<CR>", function()
        local selectedDir = sessionDir .. vim.fn.getline(".")
        M._currentSesh = selectedDir
        vim.cmd.source(selectedDir)
        vim.api.nvim_buf_delete(tmpBuffer, { force = true })
    end, { buffer = true })
end

return M

-- TODO, just figure out how opts work, but other than that it's great
