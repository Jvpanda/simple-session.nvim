local M = {}
local readWrite = require("simple-session.readWrite")
local UI = require("simple-session.getSessionWithUI")
local SDM = require("simple-session.sessionDirectoryManager")

local function setupKeymaps(keymaps)
    local defaultKeymaps = { overwrite = "<leader>as", unique = "<leader>au", saveMenu = "<leader>aa" }
    for key in pairs(defaultKeymaps) do
        if keymaps[key] == nil then
            keymaps[key] = defaultKeymaps[key]
        end
    end

    vim.keymap.set("n", keymaps.saveMenu, function()
        if SDM.isSessionSelected() == false then
            UI.openSessionRootDirectoriesUI()
        else
            UI.openSessionListUI()
        end
    end, { desc = "Choose a session to return to" })

    vim.keymap.set("n", keymaps.overwrite, function()
        readWrite.overwriteSession()
    end, { desc = "Save regular session" })

    vim.keymap.set("n", keymaps.unique, function()
        readWrite.makeUniqueSession()
    end, { desc = "Create unique session" })

    vim.keymap.set("n", "<leader>a", "", { desc = "Simple Session" })
end

M.setup = function(opts)
    opts = opts or {}
    if opts.useCustomStatus then
        vim.opt.statusline = "File: " .. "%t" .. " | Session: " .. SDM.getCurrentSessionName()
    end

    if opts.sessionRootDirectory then
        SDM.sessionRoot = opts.session_root_directory .. "/"
    end

    if opts.defaultDirectory then
        SDM.currentSessionDirectoryPath = SDM.sessionRoot .. opts.defaultDirectory .. "/"
    end

    SDM.setupRootDirectory()
    setupKeymaps(opts.keymaps)
end

return M
