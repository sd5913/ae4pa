# C closeout evidence

See [handoff](../../../../doors/c_closeout_20261122.md) for exact baseline, fixtures, status and unresolved observations. Runtime source baseline is 569b5d0; committed diagnostic code is 5bbbe65. These are automated checks, not manual TC acceptance.

- component_results.json + five standalone logs: component checks.
- ordinary_trace.json + ordinary_stress.log: 54 bidirectional returns in three seeded sessions; 3600 scheduler ticks.
- ordinary_audit.log + ordinary_screenshots/: actual Compatibility rendering of all five random ordinary residents.
- main_flow_graphics.log + graphical_trace.json + screenshots_serial/: serial actual main run, failed only at final WON assertion.
- baseline_full_mainline_headless.log: unchanged main test reproduces terminal failure.
- main_flow_diagnostic_headless.log + main_flow_trace.json: exact committed diagnostic, includes EXIT input latch state.
- initial* and interrupted*: disclosed invalid fixture attempts/interrupted capture, not product failures or PASS results.
