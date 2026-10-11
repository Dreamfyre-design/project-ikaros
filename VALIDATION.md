# Checks for this edition

The Windows Release application was built with C++17 and SFML 2.6.2. The core
tests and application export checks passed.

- The supplied Pioneer 11 scenario ran for 3,196,800 seconds at a one-second
  step, with hourly saved states. Its endpoint matched the original program's
  update in a direct comparison: zero metres difference in this build.
- Its relative endpoint error divided by distance travelled was
  `0.006349169699039044`, reproducing the original displayed `0.00634917`.
  This is an error measure: smaller values are better.
- The default export contains 889 states for each of the 10 bodies, including
  the initial state and exact final state. The circular and 13-body demos also
  completed and exported successfully.
- Fractional integration and save intervals land on the requested saved times
  and final endpoint. Duration changes skip references for another time.
- Tests cover invalid inputs, massless bodies, 25 bodies, cancellation,
  singularities, and storage size overflow. An exported scenario record can be
  loaded and run again.
- Setup, progress, results, and viewer screens were visually checked. At the
  starting sample the viewer has zero trail segments. Advancing and returning
  through saved samples shows only the trail up to the selected time.
- The original calculator, viewer, solution, and project files were checked
  against their initial SHA-256 hashes and remained unchanged.

These checks verify preservation of the numerical method and software behavior.
They do not establish the physical accuracy of the point-mass model.

For the publishing copy, reconstructed NASA/JPL Horizons requests reproduce all
60 supplied starting position/velocity components and all three Pioneer
reference-position components exactly at their printed decimal precision.
The matching query uses the Solar System Barycenter, the J2000 ecliptic plane
with the ICRF reference system, geometric states, and midnight TDB epochs.
See [data sources](docs/DATA-SOURCES.md) and the saved comparison evidence.
Original query headers and the masses' original reference publications are
unavailable; the recorded requests establish an equivalent reproducible data
selection rather than recovering the historical request.

The publishing copy changes scenario metadata to describe those matching
settings; the numerical inputs and C++ source remain unchanged. Its Windows
Release build and core tests passed, and its build copies the new license,
data evidence, and scientific/attribution documentation into the package.
