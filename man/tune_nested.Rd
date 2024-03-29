% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tune_nested.R
\name{tune_nested}
\alias{tune_nested}
\title{Function for Nested Resampling}
\usage{
tune_nested(
  tuner,
  task,
  learner,
  inner_resampling,
  outer_resampling,
  measure = NULL,
  term_evals = NULL,
  term_time = NULL,
  terminator = NULL,
  search_space = NULL,
  store_tuning_instance = TRUE,
  store_benchmark_result = TRUE,
  store_models = FALSE,
  check_values = FALSE,
  allow_hotstart = FALSE,
  keep_hotstart_stack = FALSE,
  evaluate_default = FALSE,
  callbacks = list(),
  method
)
}
\arguments{
\item{tuner}{(\link{Tuner})\cr
Optimization algorithm.}

\item{task}{(\link[mlr3:Task]{mlr3::Task})\cr
Task to operate on.}

\item{learner}{(\link[mlr3:Learner]{mlr3::Learner})\cr
Learner to tune.}

\item{inner_resampling}{(\link[mlr3:Resampling]{mlr3::Resampling})\cr
Resampling used for the inner loop.}

\item{outer_resampling}{\link[mlr3:Resampling]{mlr3::Resampling})\cr
Resampling used for the outer loop.}

\item{measure}{(\link[mlr3:Measure]{mlr3::Measure})\cr
Measure to optimize. If \code{NULL}, default measure is used.}

\item{term_evals}{(\code{integer(1)})\cr
Number of allowed evaluations.
Ignored if \code{terminator} is passed.}

\item{term_time}{(\code{integer(1)})\cr
Maximum allowed time in seconds.
Ignored if \code{terminator} is passed.}

\item{terminator}{(\link{Terminator})\cr
Stop criterion of the tuning process.}

\item{search_space}{(\link[paradox:ParamSet]{paradox::ParamSet})\cr
Hyperparameter search space. If \code{NULL} (default), the search space is
constructed from the \link{TuneToken} of the learner's parameter set
(learner$param_set).}

\item{store_tuning_instance}{(\code{logical(1)})\cr
If \code{TRUE} (default), stores the internally created \link{TuningInstanceSingleCrit} with all intermediate results in slot \verb{$tuning_instance}.}

\item{store_benchmark_result}{(\code{logical(1)})\cr
If \code{TRUE} (default), store resample result of evaluated hyperparameter
configurations in archive as \link[mlr3:BenchmarkResult]{mlr3::BenchmarkResult}.}

\item{store_models}{(\code{logical(1)})\cr
If \code{TRUE}, fitted models are stored in the benchmark result
(\code{archive$benchmark_result}). If \code{store_benchmark_result = FALSE}, models
are only stored temporarily and not accessible after the tuning. This
combination is needed for measures that require a model.}

\item{check_values}{(\code{logical(1)})\cr
If \code{TRUE}, hyperparameter values are checked before evaluation and
performance scores after. If \code{FALSE} (default), values are unchecked but
computational overhead is reduced.}

\item{allow_hotstart}{(\code{logical(1)})\cr
Allow to hotstart learners with previously fitted models. See also
\link[mlr3:HotstartStack]{mlr3::HotstartStack}. The learner must support hotstarting. Sets
\code{store_models = TRUE}.}

\item{keep_hotstart_stack}{(\code{logical(1)})\cr
If \code{TRUE}, \link[mlr3:HotstartStack]{mlr3::HotstartStack} is kept in \verb{$objective$hotstart_stack}
after tuning.}

\item{evaluate_default}{(\code{logical(1)})\cr
If \code{TRUE}, learner is evaluated with hyperparameters set to their default
values at the start of the optimization.}

\item{callbacks}{(list of \link{CallbackTuning})\cr
List of callbacks.}

\item{method}{(\code{character(1)})\cr
Deprecated. Use \code{tuner} instead.}
}
\value{
\link[mlr3:ResampleResult]{mlr3::ResampleResult}
}
\description{
Function to conduct nested resampling.
}
\examples{
# Nested resampling on Palmer Penguins data set
rr = tune_nested(
  tuner = tnr("random_search", batch_size = 2),
  task = tsk("penguins"),
  learner = lrn("classif.rpart", cp = to_tune(1e-04, 1e-1, logscale = TRUE)),
  inner_resampling = rsmp ("holdout"),
  outer_resampling = rsmp("cv", folds = 2),
  measure = msr("classif.ce"),
  term_evals = 2)

# Performance scores estimated on the outer resampling
rr$score()

# Unbiased performance of the final model trained on the full data set
rr$aggregate()
}
