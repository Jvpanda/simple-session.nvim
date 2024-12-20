M = {}
require("simple-session.readWrite")
require("simple-session.getSessionWithUI")

M._currentSesh = "/noSelectedSession."

local sessionRootDir = vim.fn.expand("~/nvim_sessions/")
local sessionDir = sessionRootDir .. "main/"
local defaultKeymaps = { overwrite = "<leader>as", unique = "<leader>au", saveMenu = "<leader>aa" }

local function setupRootDirectory(session_root_directory)
    sessionRootDir = session_root_directory

    if vim.fn.isdirectory(session_root_directory) == 0 then
        vim.fn.mkdir(session_root_directory, "p")
    end
    if vim.fn.isdirectory(sessionDir) == 0 then
        vim.fn.mkdir(sessionDir, "p")
    end
    if vim.fn.isdirectory(sessionDir .. "shada/") == 0 then
        vim.fn.mkdir(sessionDir .. "shada/", "p")
    end
end

local function setupKeymaps(keymaps)
    for key in pairs(defaultKeymaps) do
        if keymaps[key] == nil then
            keymaps[key] = defaultKeymaps[key]
        end
    end

    vim.keymap.set("n", keymaps.saveMenu, function()
        if M._currentSesh == "/noSelectedSession." then
            M.openSessionDirectoriesList(sessionRootDir)
        else
            M.openSessionList(sessionDir)
        end
    end, { desc = "Choose a session to return to" })

    vim.keymap.set("n", keymaps.overwrite, function()
        M.overwriteSession(sessionDir)
    end, { desc = "Save regular session" })

    vim.keymap.set("n", keymaps.unique, function()
        M.makeUniqueSession(sessionDir)
    end, { desc = "Create unique session" })

    vim.keymap.set("n", "<leader>a", "", { desc = "Simple Session" })
end

M.changeSessionDir = function(opt)
    sessionDir = opt
end
M.printSession = function()
    print(sessionDir)
end

M.setup = function(opts)
    opts = opts or {}
    if opts.session_root_directory then
        setupRootDirectory(opts.session_root_directory)
    end
    if opts.keymaps then
        setupKeymaps(opts.keymaps)
    end
end

return M

-- TODO, just figure out how opts work, but other than that it's great
-- Create the ability to have and switch between multiple directories
