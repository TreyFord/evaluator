context("Summarization")
test_that("Simulation summary", {
  data("simulation_results")
  data("scenario_summary")
  dat <- summarize_scenarios(simulation_results)
  expect_equivalent(as.data.frame(dat), as.data.frame(scenario_summary))
})
test_that("Simulation summary handles NAs for tc/diff exceedance", {
  data("simulation_results")
  simulation_results[1, "mean_tc_exceedance"] <- NA
  simulation_results[simulation_results$scenario_id==18 &
                       simulation_results$simulation==1, "mean_diff_exceedance"] <- NA
  dat <- summarize_scenarios(simulation_results)
  expect_gt(dat[[54,"mean_tc_exceedance"]], 0)
})

test_that("Domain summary", {
  data("simulation_results")
  data("domains")
  data("domain_summary")
  expect_equivalent(summarize_domains(simulation_results), domain_summary)
})

test_that("Summarize to disk", {
  tmpdata <- file.path(tempdir(), "data")
  dir.create(tmpdata)

  result <- summarize_to_disk(evaluator::simulation_results, evaluator::domains,
                              results_dir = tmpdata)
  expect_equal(nrow(result), 2)
  unlink(tmpdata, recursive = TRUE)
})
