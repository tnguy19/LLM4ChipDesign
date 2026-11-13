# Waveforms (raw simulator output)

- `primary.vcd` / `advanced.vcd` : raw VCD dumps produced directly by Icarus Verilog
  (`$dumpfile` in the testbenches) — the actual waveform data from the simulation.
- `primary.gtkw` / `advanced.gtkw` : GTKWave session files that open the VCD with the
  relevant signals preselected.

## View in GTKWave (part of the OSS CAD Suite)
```bash
gtkwave primary.gtkw      # or: gtkwave primary.vcd
gtkwave advanced.gtkw
```

## Regenerate the VCDs
```bash
# from submission/ :
iverilog -g2012 -o e.out rtl/*.v tb/tb_agentic.v && vvp e.out        # writes exploit.vcd (primary)
cd advanced_trojan && iverilog -g2012 -o a.out rtl/*.v tb/tb_agentic.v && vvp a.out   # advanced
```
