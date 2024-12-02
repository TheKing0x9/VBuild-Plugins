#! /usr/bin/luajit

local lfs = require 'lfs'

local list_dir = lfs.dir
local insert = table.insert
local attributes = lfs.attributes

local utils = vbuild.utils
local config = vbuild.config
local command = vbuild.command

local dir = modules.dir
local argparse = modules.argparse
local split_path = utils.split_path

local compiler = "iverilog"
local build_dir = nil

local plugin = {}

-- called after all the plugins are loaded and the configuration is set
function plugin.init()
    build_dir = dir(config.Verilog.build_path, true)
end

local function build_module(name, ref, build_dir, directories)
    -- check if the directory exists
    if not utils.directory_exists(build_dir.path) then
        print("Build directory does not exists. Creating ...")
        lfs.mkdir(build_dir.path)
    end

    if not ref then
        error("Module " .. name .. " does not exists. Exiting ...")
    end

    local tb = name .. '_tb'
    if not vbuild.testbenches[tb] then
        error("No testbench found for module " .. name .. ". Skipping...")
    end

    local output = dir(build_dir):join(name).path
    local command = compiler .. " -o " .. output .. " " .. ref .. " " .. vbuild.testbenches[tb]

    for i = 1, #directories do
        command = command .. " -y" .. directories[i]
    end

    print("Building module " .. name .. " ...")
    print(command)

    local code = os.execute(command)
    if code ~= 0 then
        error("Error building module " .. name)
    end
end

local function execute_module(module, build_path)
    local current = lfs.currentdir()
    lfs.chdir(build_path.path)
    local process = io.popen("vvp " .. module)

    if process == nil then
        error("Error executing module " .. module, 0)
        return
    end

    local output = process:read("*a")
    process:close()
    print(output)

    lfs.chdir(current)
end

local function cleanup(build_path)
    print("Cleaning up...")
    for file in list_dir(build_path.path) do
        if file ~= "." and file ~= ".." then
            print("Removing " .. file)
            assert(os.remove(dir(build_path):join(file).path))
        end
    end
end

local function view_module(module, build_path)
    local output = dir(build_path):join(module .. '_tb.vcd')
    os.execute("gtkwave " .. output.path)
end

local function main(args)
    local parser = argparse("builder", "Build script for the project")
    parser:argument("module", "The module to build")
    parser:option("-j --threads", "Number of threads for compiling", 1)
    parser:flag("-v --view", "Open gtkwave after building")
    parser:flag("-c --clean", "Enables auto cleaning output")

    local args, err = parser:parse(args)
    build_module(args.module, vbuild.files[args.module], build_dir,
        vbuild.watched_dirs)
    execute_module(args.module, build_dir)

    if args.view then
        view_module(args.module, build_dir)
    end

    if args.clean then
        cleanup(build_dir)
    end
end

command.register('builder', function(args)
    main(args)
end)

command.register('build', function(args)
    local name = args[1]
    build_module(name, vbuild.files[name], build_dir,
        vbuild.watched_dirs)
end)

command.register('execute', function(args)
    local name = args[1]
    execute_module(name, build_dir)
end)

command.register('clean', function()
    cleanup(build_dir)
end)

command.register('view', function(args)
    local name = args[1]
    view_module(name, build_dir)
end)

vbuild.add_default_config('Verilog', {
    flags = { '-Wall', },
    build_path = 'build',
})

return plugin
