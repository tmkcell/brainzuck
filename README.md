# brainzuck

A brainfuck interpreter written in zig

## Running 
### 1. Clone repo
```
git clone https://github.com/tmkcell/brainzuck.git && cd brainzuck
```
### 2. Compile with zig (resulting binary is in zig-out/bin)
```
zig build
```

Optionally, run the hello world test with `zig build test`

### 3. Run a brainfuck program
```
./zig-out/bin/brainzuck [absolute path to .bf file]
```
