return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    -- 'theHamsta/nvim-dap-virtual-text',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
  },
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'
    return {
      { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
      { '<F1>', dap.step_into, desc = 'Debug: Step Into' },
      { '<F2>', dap.step_over, desc = 'Debug: Step Over' },
      { '<F3>', dap.step_out, desc = 'Debug: Step Out' },
      { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
      {
        '<leader>B',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
      unpack(keys),
    }
  end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        -- 'codelldb',
        'delve',
      },
    }

    -- require('nvim-dap-virtual-text').setup()

    dap.set_log_level 'TRACE'

    -- [[ CODELLDB ADAPTER ]]
    -- local install_root_dir = vim.fn.stdpath 'data' .. '/mason'
    -- local extension_path = install_root_dir .. '/packages/codelldb/extension/'
    -- local codelldb_path = extension_path .. 'adapter/codelldb'

    -- dap.adapters.codelldb = {
    --   type = 'executable',
    --   command = codelldb_path,
    -- }
    --
    --[[ GDB ADAPTER ]]
    dap.adapters.gdb = {
      type = 'executable',
      command = 'gdb',
      args = { '--interpreter=dap', '--eval-command', 'set print pretty on' },
      singleThread = true,
    }
    --
    -- [[ lldb-dap ADAPTER ]]
    -- dap.adapters.lldb = {
    --   type = 'executable',
    --   command = '/usr/bin/lldb-dap-19', -- adjust as needed, must be absolute path
    --   name = 'lldb',
    -- }
    --
    -- [[ VSCODE-CPPTOOLS ]]
    -- dap.adapters.cppdbg = {
    --   id = 'cppdbg',
    --   type = 'executable',
    --   command = '/home/vladislav-markov/tools/extension/debugAdapters/bin/OpenDebugAD7',
    -- }

    -- dap.configurations.c = {
    -- [[ CODELLDB ]]
    -- {
    --   name = 'Launch (build directory)',
    --   type = 'codelldb',
    --   request = 'launch',
    --   program = function()
    --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --   end,
    --   cwd = '${workspaceFolder}',
    --   stopOnEntry = true, -- false,
    --   -- MULTITHREADING-SPECIFIC OPTIONS
    --   runInTerminal = false, -- keeps LLDB’s non-stop mode available
    --   terminal = 'integrated',
    --   stopThreads = 'all',
    --   initCommands = function()
    --     return {
    --       'process handle -p true -s true SIGSTOP', -- let LLDB stop everyone
    --       'settings clear target.process.thread.step-avoid-regexp',
    --       -- keep other threads running while you inspect one
    --       -- 'settings set target.process.thread.step-avoid-regexp .*',
    --       -- "settings set target.process.thread.step-avoid-regexp ''",
    --       'settings set target.process.thread.step-in-avoid-nodebug false',
    --     }
    --   end,
    -- },
    -- {
    --   name = 'Attach to process',
    --   type = 'codelldb',
    --   request = 'attach',
    --   pid = require('dap.utils').pick_process,
    --   cwd = '${workspaceFolder}',
    -- },
    --
    -- [[ GDB ]]
    dap.configurations.c = {
      {
        name = 'Run executable (GDB)',
        type = 'gdb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtBeginningOfMainSubprogram = false,
      },
      {
        name = 'Select and attach to process',
        type = 'gdb',
        request = 'attach',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        pid = function()
          local name = vim.fn.input 'Executable name (filter): '
          return require('dap.utils').pick_process { filter = name }
        end,
        cwd = '${workspaceFolder}',
      },
      {
        name = 'Attach to gdbserver :1234',
        type = 'gdb',
        request = 'attach',
        target = 'localhost:1234',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
      },
    }

    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = dap.configurations.c

    -- [[ LLDB-VSCODE ]]
    -- dap.configurations.cpp = {
    --   {
    --     name = 'Launch',
    --     type = 'lldb',
    --     request = 'launch',
    --     program = function()
    --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --     end,
    --     cwd = '${workspaceFolder}',
    --     stopOnEntry = false,
    --     args = {},
    --     initCommands = function()
    --       return 'settings set target.run-all-threads false'
    --     end,
    --
    --     -- 💀
    --     -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --     --
    --     --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --     --
    --     -- Otherwise you might get the following error:
    --     --
    --     --    Error on launch: Failed to attach to the target process
    --     --
    --     -- But you should be aware of the implications:
    --     -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    --     -- runInTerminal = false,
    --   },
    -- }

    -- dap.configurations.cpp = {
    --   {
    --     name = 'Launch file',
    --     type = 'cppdbg',
    --     request = 'launch',
    --     program = function()
    --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --     end,
    --     cwd = '${workspaceFolder}',
    --     stopAtEntry = true,
    --   },
    --   {
    --     name = 'Attach to gdbserver :1234',
    --     type = 'cppdbg',
    --     request = 'launch',
    --     MIMode = 'gdb',
    --     miDebuggerServerAddress = 'localhost:1234',
    --     miDebuggerPath = '/usr/bin/gdb',
    --     cwd = '${workspaceFolder}',
    --     program = function()
    --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --     end,
    --   },
    -- }
    --
    -- dap.configurations.c = dap.configurations.cpp
    -- dap.configurations.rust = dap.configurations.cpp

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
