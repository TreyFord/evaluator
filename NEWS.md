# evaluator 0.3.0.900 (unreleased)

* Prep for new development round

# evaluator 0.3.0

* Data structure changes 
    * IDs for simulations and capabilities no longer need to be numeric. ID 
    styles in the format of "FOO-123" and "MY_Scenario" are now supported.
    * Quantified scenarios now store parameters for TEF, TC, LM, and DIFF 
    values as list columns. This allows non L/ML/H/CONF distributions to be 
    more easily sampled. Qualitative scenario structure is unchanged so this 
    should have no impact on most users.
    * `capabilities` table has renamed the `id` column to `capability_id` to 
    be consistent with other ID columns throughout the schema. Survey (Excel) 
    users are not impacted by this change.
* Model interface change - With the unification on list columns for OpenFAIR 
parameters, the top level model objects no longer take a dedicated `diff_estimates` 
option. The `run_simulations()` function accounts for this change. Users using 
the standard flow will not be impacted.
* `summarize_domains()` - Incorporates the now removed 
`calculate_domain_impact()`  and `calculate_weak_domains()` functions. As part 
of this consolidation, the `mean_tc_exceedance` and  `mean_diff_exceedance` 
calculations are improved by handling NAs in some simulations without zeroing 
out the entire calculation.
* `summarize_domains()` - Properly calculates `mean_diff_exceedance` when there 
all threat events are successfully avoided.
* `generate_heatmap()` - Takes a `domain_summary` input rather than the 
deprecated `domain_impact` structure.

## Bug Fixes
* Using distributions not in the `base` or `stats` namespaces was practically 
impossible. All atomic OpenFAIR functions have been refactored to take a 
fully qualified function (i.e. `EnvStats::rnormTrunc`).
* `explore_scenarios()` was trying to assign a mappings variable to the global 
context, which rightly failed. Scaled back the assignment to the current 
scope.
* `select_loss_opportunities()` properly returns an NA for the threat & difficulty 
exceedance calculations when there are no threat events in a given simulated 
period.
* `summarize_scenarios()` - correctly handles scenarios in which no threat 
events occur in a given simulation. This bug was limited to `mean_tc_exceedance`. 
For previously run simulations, re-summarizing the `scenario_results` will 
generate corrected values.
* `calculate_max_losses()` - no longer returns a duplicate set of results if 
not passed any outliers.

## Improvements
* `run_simulations()` - New `ale_maximum` parameter allows an absolute cap on 
per simulation annual losses to be set. This is an interim step in lieu of 
full hierarchical interaction modelling.
* `run_simulations()` - Errors encountered during runs are now reported better.
* `run_simulations()` - Implements parallel execution via the `furrr` package. 
To run simulations across all cores of a local machine, load `furrr` and 
run `plan(multicore)` before launching an analysis. For more information, 
see the `furrr::future_map()` documentation.
* `sample_lm()` and `sample_tc()` check if they are asked to generate zero 
requested samples, bypassing calling the underlying generation function. This 
avoids problems with generating functions which do not gracefully handle being 
asked to sample a non positive number (zero) of events.
* `load_data()` now fully specifies the expected CSV file formats, avoiding 
possible surprises and making invocations less noisy on the console.
* Removed all deprecated standard-evaluation tidyverse verbs in favor of 
`rlang::.data` constructs, making CRAN checks much simpler.
* Minor documentation cleanup.

# evaluator 0.2.3

## Bug Fixes
* Additional logic in tests to verify that supplemental packages are available, 
skipping the test if said packages are not installed.
* Update tests to convert tibbles to data.frames prior to comparison as a work 
around for [dplyr/2751](https://github.com/tidyverse/dplyr/issues/2751).

# evaluator 0.2.2

## Analysis Change
* Previous versions sampled threat frequency (TEF) as a continuous distribution.
    Threat event counts are discrete (they either happen or don't in a given 
    simulated period), so this previous method was incorrect and inflated threat 
    counts. The differences are small in the standard 10,000 evaluation range, 
    but users should note the change.
* Part of the discretization step for TEF has a positive side effect of making 
    the threat_event column in data objects an integer rather than a double-
    long. As this is still a numeric type, there should be no impact on 
    users for this change apart from a slightly tidyer data output.

## Bug Fixes
* Update risk_dashboard to not cache any chunks. This keeps `render` from 
    from trying to write to the package install directory.
* Updated tests to use four significant digits where long reference values are 
    passed, avoiding precision issues on machines without long doubles.


# evaluator 0.2.1

## Bug Fixes
* Document optional dependency on pandoc and add test skip logic to avoid 
    rmarkdown tests on systems where pandoc is not available.
    + Add testing to travis matrix for Linux builds with and without pandoc.
* run_analysis script was missing namespace calls for `readr::cols`.
* All rmarkdown calls now specify an `intermediates_dir` value of `tempdir()`. 
    This can be overwritten on the function call if needed.
* Report generation is now much quieter by default.

# evaluator 0.2.0

## New Functionality
* New sample dataset: `mappings` contains sample qualitative to quantitative 
  parameters.
* risk_dashboard expects a mandatory output parameter to the desired rendered 
  output.
* New `pkgdown` generated web documentation at https://evaluator.severski.net.
* Refactored `generate_report` function.
    * Now accepts `format` parameter to specify HTML, PDF, or Word
    * Optional `styles` parameter allows user to supply custom CSS or Word
    reference document to customize styles and fonts
    * RMarkdown 1.8.2 or greater (currently GitHub only) required to work 
    around the temporary file deletion issue specified in 
    https://github.com/rstudio/rmarkdown/issues/1184. Use
    `devtools::install_github("rstudio/rmarkdown", "b84f706")` or greater.
* Expose OpenFAIR model selection in `run_simulation()` call
    * Provide default TEF/TC/DIFF/LM OpenFAIR model
* New `create_templates()` function for populating starter/sample files, making 
  starting a fresh analysis easier than ever!
* Experimental quick start script, run_analysis.R, supplied with `create_templates()`.
* All default directories normalized to ~/evaluator/[inputs|results]
* New OpenFAIR primitives:
    * sample_tef
    * sample_lm
    * sample_tc
    * sample_diff
    * sample_vuln
* New composition functions:
    * compare_tef_vuln
    * select_loss_opportunities
* New difficulty composition functions:
    * get_mean_control_strength
    
## Bug Fixes
* Improved help documentation on many functions
* Update of usage vignette
* Auto loads `extrafont` database for better font detection
    * Falls back to standard `sans` family when none of the preferred options 
      are available
* Drop use of `tcltk` progress bar in favor of console-compatible 
    `dplyr::progress_estimated()`. Also enables reduced package dependencies.
* Tests and code coverage reporting added
    * Improve faulty `capabilities` validation
* Removed dependency on `purrrlyr`

## Miscellaneous Changes
* `generate_report` defaults to creating a MS Word document as the output type

# evaluator 0.1.1

* Replaced dependency on `modeest` with a slimmer `statip` dependency
* Removed dependency on `magrittr`
* Default (overridable) locations of input and results directories now consistently set to "~/data" and "~/results" respectively
* `generate_report()` now takes an optional `focus_scenario_ids` parameter to override the scenarios on which special emphasis (usually executive interest) is desired.
* Improve user experience for optional packages. User is now prompted to install optional dependencies (shiny, DT, flexdashboard, statip, rmarkdown, etc.) when running reporting functionality which requires them.
* Substantial improvements in the sample analysis flow detailed in the usage vignette. You can now actually run all the commands as-is and have them work, which was previously "challenging".
* `summarize_all()` renamed to the more descriptive `summarize_to_disk()` to avoid dplyr conflict
* Add requirement for at least pander v0.6.1 for `tibble` compatibility
* Substantial refactoring on vignette
  * Added missing save steps
  * Corrected package name for `Viewer` to `rstudioapi` 
  * Fixed a few incorrect placeholders
  * Properly committed compiled files to package for distribution and installation
* Update all tidyverse calls to account for deprecations and split out of `purrrlyr`
* Windows CI builds added via Appveyor
* Use `annotate_logticks()` over manual breaks on risk_dashboard

# evaluator 0.1.0

* Initial submission to CRAN
