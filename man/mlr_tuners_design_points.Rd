% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TunerDesignPoints.R
\name{mlr_tuners_design_points}
\alias{mlr_tuners_design_points}
\alias{TunerDesignPoints}
\title{Hyperparameter Tuning with via Design Points}
\description{
Subclass for tuning w.r.t. fixed design points.

We simply search over a set of points fully specified by the user. The points
in the design are evaluated in order as given.
}
\section{Dictionary}{

This \link{Tuner} can be instantiated via the \link[mlr3misc:Dictionary]{dictionary}
\link{mlr_tuners} or with the associated sugar function \code{\link[=tnr]{tnr()}}:\preformatted{mlr_tuners$get("design_points")
tnr("design_points")
}
}

\section{Parallelization}{

In order to support general termination criteria and parallelization, we
evaluate points in a batch-fashion of size \code{batch_size}. Larger batches mean
we can parallelize more, smaller batches imply a more fine-grained checking
of termination criteria. A batch contains of \code{batch_size} times \code{resampling$iters} jobs.
E.g., if you set a batch size of 10 points and do a 5-fold cross validation, you can
utilize up to 50 cores.

Parallelization is supported via package \CRANpkg{future} (see \code{\link[mlr3:benchmark]{mlr3::benchmark()}}'s
section on parallelization for more details).
}

\section{Logging}{


All \link{Tuner}s use a logger (as implemented in \CRANpkg{lgr}) from package
\CRANpkg{bbotk}.
Use \code{lgr::get_logger("bbotk")} to access and control the logger.
}

\section{Parameters}{


\describe{
\item{\code{batch_size}}{\code{integer(1)}\cr
Maximum number of configurations to try in a batch.}
\item{\code{design}}{\link[data.table:data.table]{data.table::data.table}\cr
Design points to try in search, one per row.}
}

}

\section{Progress Bars}{


\verb{$optimize()} supports progress bars via the package \href{https://CRAN.R-project.org/package=progressr}{\pkg{progressr}}
combined with a \link[bbotk]{Terminator}. Simply wrap the function in
\code{progressr::with_progress()} to enable them. We recommend to use package
\href{https://CRAN.R-project.org/package=progress}{\pkg{progress}} as backend; enable with \code{progressr::handlers("progress")}.

}

\examples{
library(mlr3)
library(paradox)
library(data.table)
search_space = ParamSet$new(list(
  ParamDbl$new("cp", lower = 0.001, upper = 0.1)
))
terminator = trm("evals", n_evals = 3)
instance = TuningInstanceSingleCrit$new(
  task = tsk("iris"),
  learner = lrn("classif.rpart"),
  resampling = rsmp("holdout"),
  measure = msr("classif.ce"),
  search_space = search_space,
  terminator = terminator
)
design = data.table(cp = c(0.1, 0.01))
tt = tnr("design_points", design = design)
# modifies the instance by reference
tt$optimize(instance)
# returns best configuration and best performance
instance$result
# allows access of data.table of full path of all evaluations
instance$archive
}
\seealso{
Package \CRANpkg{mlr3hyperband} for hyperband tuning.

Other Tuner: 
\code{\link{mlr_tuners_cmaes}},
\code{\link{mlr_tuners_gensa}},
\code{\link{mlr_tuners_grid_search}},
\code{\link{mlr_tuners_nloptr}},
\code{\link{mlr_tuners_random_search}}
}
\concept{Tuner}
\section{Super classes}{
\code{\link[mlr3tuning:Tuner]{mlr3tuning::Tuner}} -> \code{\link[mlr3tuning:TunerFromOptimizer]{mlr3tuning::TunerFromOptimizer}} -> \code{TunerDesignPoints}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-new}{\code{TunerDesignPoints$new()}}
\item \href{#method-clone}{\code{TunerDesignPoints$clone()}}
}
}
\if{html}{
\out{<details open ><summary>Inherited methods</summary>}
\itemize{
\item \out{<span class="pkg-link" data-pkg="mlr3tuning" data-topic="Tuner" data-id="format">}\href{../../mlr3tuning/html/Tuner.html#method-format}{\code{mlr3tuning::Tuner$format()}}\out{</span>}
\item \out{<span class="pkg-link" data-pkg="mlr3tuning" data-topic="Tuner" data-id="print">}\href{../../mlr3tuning/html/Tuner.html#method-print}{\code{mlr3tuning::Tuner$print()}}\out{</span>}
\item \out{<span class="pkg-link" data-pkg="mlr3tuning" data-topic="TunerFromOptimizer" data-id="optimize">}\href{../../mlr3tuning/html/TunerFromOptimizer.html#method-optimize}{\code{mlr3tuning::TunerFromOptimizer$optimize()}}\out{</span>}
}
\out{</details>}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-new"></a>}}
\if{latex}{\out{\hypertarget{method-new}{}}}
\subsection{Method \code{new()}}{
Creates a new instance of this \link[R6:R6Class]{R6} class.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{TunerDesignPoints$new()}\if{html}{\out{</div>}}
}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-clone"></a>}}
\if{latex}{\out{\hypertarget{method-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{TunerDesignPoints$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
