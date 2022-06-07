# DP-C  

- `CommonTypes.vhd` - Contains all common parameters for all cores + testbenches
- `DP_Helper`  - Container helper function fro DP_C_tb

## Instructions
The `.src/sim` folder is a modelsim (vsim) project. The ordering generated by Quartus have ordering issues.

- Each entity have its own testbench (`_tb`) file demonstrating the entity's operation.
- Compile all files under `./src/core` in vsim. Compile `./src/tb/TdmaMin/TdmaMinTypes`.
- Compile and build ip libaray for tdmaMin IP under `./src/tb/TdmaMin`.
  - If not running DP_C testbench, only the `TdmaMinTypes` is needed.

**Note:**

- vsim simulation initiated from `rtl simulation` in Quartus did not automatically order the compilation ordering correctly. Therefore, to simulate the design for various components and view the tb, manual compilation (through compile option in model sim) of lower-level modules are required.
- Logic synthesis can be upwards 0f 20 minutes.
- Currently exceeding resources.