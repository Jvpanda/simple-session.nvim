# simple-session.nvim
A simple session manager that wraps mksession and shada functionality
This is my first plugin it's more of a personal project but it works perfectly well


What it saves:
Everything option in mksession such as windows and buffers
For shada it only saves marks


How to use:
Create directories in a root directory
Those directories each house whatever sessions you want to save and their shada data

You can save 3 different ways:
    Save by unique name, which creates a new unique save
    Save by increment, which is accessed by not typing a unique name
    Save by overwrite, which is automatic

If you are in a session save by overwrite, and increment uses the current session path
If you are not in a session, they will save the name of the current working directory
If there is an existing save with the same name, it will either increment or overwrite for you starting at 0

Finally you can access a custom menu where you can select saves and access directories
If you select a new directory, it will get rid of the current session and all new saves will be put in that directory


Installation:
Use your package manager
Simply call the setup or opts to get it working

Default opts:
opts = {
keymaps = {unique = '<leader>au', saveMenu = '<leader>aa', overwrite = '<leader>as'},
session_root_directory = "~/nvim_sessions" 
        }

