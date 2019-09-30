context("mlr_tuners")

test_that("mlr_tuners", {
  expect_dictionary(mlr_tuners)
  for (key in mlr_tuners$keys()) {
    expect_tuner(tnr(key))
  }
})

test_that("mlr_tuners sugar", {
  tuner = tnr("random_search")
  expect_tuner(tuner)
})