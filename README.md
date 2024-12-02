# VBuild Plugins

This repository contains a collection of plugins for [VBuild](https:www.github.com/theking0x9/vbuild). More documentation coming soon.

To install download the plugin and place it in the `plugins` directory of your VBuild project.

## Plugins

#### [IVerilog](https://raw.githubusercontent.com/theking0x9/vbuild-plugins/refs/heads/main/plugins/iverilog.lua)

IVerilog based compiler for VBuild

<details>
<summary>Additional Details</summary>

**Author** : theking0x9 </br>
**Version** : 0.1.2 </br>
**License** : MIT </br>
**Dependencies** : iverilog </br>
**Configuration fields** :
```toml
[Verilog]
build_path = "build"    # path to the build directory
flags = ['-Wall']       # flags to be passed to iverilog compiler
```
</details>

---

#### [Testbench](https://raw.githubusercontent.com/theking0x9/vbuild-plugins/refs/heads/main/plugins/testbench.lua)

Automatically create Verilog testbenches from a specified template

<details>
<summary>Additional Details</summary>

**Author** : theking0x9 </br>
**Version** : 0.0.1 </br>
**License** : MIT </br>
**Dependencies** : None </br>
**Configuration fields** : None <br/>
</details>

---
