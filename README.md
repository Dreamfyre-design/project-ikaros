# Project Ikaros

An educational C++ Newtonian gravity simulator for Windows. Define any number
of bodies in a text file, calculate their motion, view saved positions in 3D,
and export CSV results.

This is an educational point-mass model. Its software checks demonstrate
reproducibility and expected behavior; they do not establish spacecraft-navigation
accuracy. See [scientific limitations](docs/SCIENTIFIC-LIMITATIONS.md).

## Download and run on Windows

On the GitHub repository page, open **Releases** and download the Windows
application ZIP when a release is available. Extract the entire ZIP, then
double-click **Run Ikaros.cmd**. Keep `bin/`, `scenarios/`, and `licenses/`
together with the launcher. The source repository does not include the compiled
application; use a release ZIP or [build from source](#build-from-source).

1. Choose **Pioneer 11 at Saturn**, **Circular orbit demo**, or **Many-body demo**.
   Use **Browse scenario...** for another scenario.
2. Adjust duration, integration step, and saving interval.
3. Select **Run simulation**. A running calculation can be cancelled.
4. Select **Open 3D viewer** or **Open results folder** when it finishes.

Each successful run creates a new `results/` folder containing
`trajectories.csv`, `summary.txt`, and `scenario-used.txt`. CSV data remain in the
input coordinate frame regardless of camera settings. A folder containing
`INCOMPLETE.txt` has an unfinished export.

**Edit scenario file** opens the selected file in a text editor. Save edits and
select **Reload file**. Launcher fields override the file's run settings for that
run. The [user guide](USER-GUIDE.html) provides more interface detail.

## 3D viewer

Drag to rotate and scroll over the plotting area to zoom. Playback controls step
through saved states or animate them. Trails stop at the displayed time and
shorten when playback moves backward; future trajectories are hidden.

Select bodies in the body list; on-screen help explains other controls. Hidden
bodies still affect gravity. Marker sizes do not represent physical radii.

## Create a scenario

Use a `.txt` file. Blank lines and lines beginning with `#` are ignored.

```ini
[simulation]
title = My gravity experiment
epoch = Starting instant and time scale of my data
frame = Coordinate origin and axes of my data
duration_seconds = 3600
time_step_seconds = 1
sample_interval_seconds = 60

[view]
focus = Central body
reference = Central body
target = Probe
hidden =

[bodies]
name,mass_kg,x_m,y_m,z_m,vx_m_s,vy_m_s,vz_m_s
Central body,5.97219e24,0,0,0,0,0,0
Probe,0,7000000,0,0,0,0,7500,0
```

Add or remove body rows. Names must be unique. Use kilograms, metres, metres per
second, and seconds; scientific notation is accepted. A zero-mass test particle
feels gravity but does not exert it. Quote CSV names containing commas.

View settings identify bodies by name: `reference` chooses the moving camera
frame (blank for a fixed frame), `target` selects distance inspection, and
`hidden` accepts comma-separated body names.

All initial states must use the same epoch, coordinate frame, and time scale.
The `epoch` and `frame` labels are metadata: editing them does not transform
coordinates or convert times. The author confirms that the Pioneer data came
from JPL Horizons. Reconstructed requests to the current Horizons API exactly
matched all 60 starting position/velocity components and the three reference
position components after conversion to SI units. The matching settings use the
Solar System barycenter, ICRF with the ecliptic of J2000.0, TDB midnight epochs,
and geometric vectors without aberration corrections. The original query
headers were not retained, so this reproduces the values rather than recovering
the historical requests. See [starting data and provenance](docs/DATA-SOURCES.md)
for evidence and settings. The two demos use constructed inputs.

An optional endpoint reference uses the input frame and metres:

```ini
[reference]
time_seconds = 3600
x_m = 0
y_m = 0
z_m = 0
```

Replace the examples with a valid reference and set `[view] target`. All four
reference fields are required together. Comparison is skipped if the run ends
at another time.

## Calculation and validation

The implementation retains the original calculator's update method:

```text
v_new = v_old + a_old * dt
x_new = x_old + 0.5 * (v_old + v_new) * dt
G = 6.6743e-11 m^3 kg^-1 s^-2
```

All step accelerations use the old positions. This version does not implement
Velocity-Verlet. Steps shorten at requested saving times and the final time,
so changing the saving interval can also change the integration steps.

The default Pioneer run covers 37 days with a one-second integration step and
hourly saving: 889 states per body including both endpoints. It reproduces the
original relative endpoint error, approximately `0.006349169699`, or **0.6349% of
the estimated distance travelled**. The metric is endpoint position error
divided by estimated path length, not a percentage of prediction accuracy.
See [validation records](VALIDATION.md) and
[scientific limitations](docs/SCIENTIFIC-LIMITATIONS.md).

## Build from source

Requirements: a C++17 compiler, CMake 3.21 or newer, and an SFML 2.6.x SDK
compatible with your compiler and architecture. The interface targets Windows
and does not support SFML 3.

From a Visual Studio developer shell, configure a fresh build directory using
your own SDK location:

```powershell
cmake -S . -B build -A x64 -DSFML_ROOT="C:/Libraries/SFML-2.6.2"
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure
```

Launch `build/Run Ikaros.cmd`. The executable is `build/bin/Ikaros.exe`; the
build copies its SFML DLLs and application files beside it. Windows system
fonts are used without redistributing them.

Core tests can be built without SFML or the Windows interface:

```powershell
cmake -S . -B build-tests -DIKAROS_BUILD_APP=OFF -DBUILD_TESTING=ON
cmake --build build-tests --config Release
ctest --test-dir build-tests -C Release --output-on-failure
```

## Authorship and licenses

**Dreamfyre-design** developed the original calculator and numerical update
method and supplied the Pioneer inputs. OpenAI Codex assisted with the
generalized core implementation, parser, interface, viewer, tests, build setup,
and documentation. See [attribution](docs/ATTRIBUTION.md) for the full account.

Project code is distributed under the [MIT license](LICENSE). Third-party
components retain their own licenses: SFML's notice is in
[SFML-LICENSE.md](licenses/SFML-LICENSE.md), with additional credits in
[SFML-THIRD-PARTY.md](licenses/SFML-THIRD-PARTY.md).

