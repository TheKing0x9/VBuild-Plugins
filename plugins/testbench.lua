local dir = modules.dir

local tb_stub =
[[
module %s_tb();
    initial begin
        $dumpfile("%s_tb.vcd");
        $dumpvars(0, %s_tb);
    end
endmodule
]]

local function create_tb(args)
    local name = args[1]
    local parent = args[2]

    local tb = string.format(tb_stub, name, name, name)
    parent = parent or vbuild.config.Sources.testbench_dirs[1]
    local file, err = io.open(dir(parent, true):join(name .. "_tb.v").path, "w")
    if file == nil then
        error("Failed to create testbench file for " .. name .. '\n' .. err)
    end
    file:write(tb)
    io.close(file)
end

vbuild.command.register("create_tb", create_tb)
