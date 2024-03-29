#' @title Class for Tuning Objective
#'
#' @description
#' Stores the objective function that estimates the performance of hyperparameter configurations.
#' This class is usually constructed internally by the [TuningInstanceSingleCrit] or [TuningInstanceMultiCrit].
#'
#' @template param_task
#' @template param_learner
#' @template param_resampling
#' @template param_measures
#' @template param_store_models
#' @template param_check_values
#' @template param_store_benchmark_result
#' @template param_allow_hotstart
#' @template param_keep_hotstart_stack
#' @template param_callbacks
#'
#' @export
ObjectiveTuning = R6Class("ObjectiveTuning",
  inherit = Objective,
  public = list(

    #' @field task ([mlr3::Task]).
    task = NULL,

    #' @field learner ([mlr3::Learner]).
    learner = NULL,

    #' @field default_values (named list).
    #'  Default hyperparameter values of the learner.
    default_values = NULL,

     #' @field resampling ([mlr3::Resampling]).
    resampling = NULL,

    #' @field measures (list of [mlr3::Measure]).
    measures = NULL,

    #' @field store_models (`logical(1)`).
    store_models = NULL,

    #' @field store_benchmark_result (`logical(1)`).
    store_benchmark_result = NULL,

    #' @field archive ([ArchiveTuning]).
    archive = NULL,

    #' @field hotstart_stack ([mlr3::HotstartStack]).
    hotstart_stack = NULL,

    #' @field allow_hotstart (`logical(1)`).
    allow_hotstart = NULL,

    #' @field keep_hotstart_stack (`logical(1)`).
    keep_hotstart_stack = NULL,

    #' @field callbacks (List of [CallbackTuning]s).
    callbacks = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param archive ([ArchiveTuning])\cr
    #'   Reference to archive of [TuningInstanceSingleCrit] | [TuningInstanceMultiCrit].
    #'   If `NULL` (default), benchmark result and models cannot be stored.
    initialize = function(task, learner, resampling, measures, store_benchmark_result = TRUE, store_models = FALSE, check_values = TRUE, allow_hotstart = FALSE, keep_hotstart_stack = FALSE, archive = NULL, callbacks = list()) {
      self$task = assert_task(as_task(task, clone = TRUE))
      self$learner = assert_learner(as_learner(learner, clone = TRUE))
      self$default_values = self$learner$param_set$values
      learner$param_set$assert_values = FALSE
      self$measures = assert_measures(as_measures(measures), task = self$task, learner = self$learner)

      self$store_models = assert_flag(store_models)
      self$store_benchmark_result = assert_flag(store_benchmark_result) || self$store_models
      self$allow_hotstart = assert_flag(allow_hotstart) && any(c("hotstart_forward", "hotstart_backward") %in% learner$properties)
      if (self$allow_hotstart) self$hotstart_stack = HotstartStack$new()
      self$keep_hotstart_stack = assert_flag(keep_hotstart_stack)
      self$archive = assert_r6(archive, "ArchiveTuning", null.ok = TRUE)
      if (is.null(self$archive)) self$allow_hotstart = self$store_benchmark_result = self$store_models = FALSE
      self$callbacks = assert_callbacks(as_callbacks(callbacks))

      super$initialize(id = sprintf("%s_on_%s", self$learner$id, self$task$id), properties = "noisy",
        domain = self$learner$param_set, codomain = measures_to_codomain(self$measures),
        constants = ps(resampling = p_uty()), check_values = check_values)

      # set resamplings in constants
      resampling = assert_resampling(as_resampling(resampling, clone = TRUE))
      if (!resampling$is_instantiated) resampling$instantiate(task)
      self$resampling = resampling
      self$constants$values$resampling = list(resampling)
    }
  ),

  private = list(
    .eval_many = function(xss, resampling) {
      context = ContextEval$new(self)
      private$.xss = xss

      private$.design = if (self$allow_hotstart) {
        # create learners from set of hyperparameter configurations and hotstart models
        learners = map(private$.xss, function(x) {
          learner = self$learner$clone(deep = TRUE)
          learner$param_set$values = insert_named(learner$param_set$values, x)
          learner$hotstart_stack = self$hotstart_stack
          learner
        })
        data.table(task = list(self$task), learner = learners, resampling = resampling)
      } else if (length(resampling) > 1) {
        param_values = map(xss, function(xs) list(xs))
        data.table(task = list(self$task), learner = list(self$learner), resampling = resampling, param_values = param_values)
      } else {
        benchmark_grid(self$task, self$learner, resampling, param_values = list(xss))
      }

      call_back("on_eval_after_design", self$callbacks, context)

      # learner is already cloned, task and resampling are not changed
      private$.benchmark_result = benchmark(
        design = private$.design,
        store_models = self$store_models || self$allow_hotstart,
        allow_hotstart = self$allow_hotstart,
        clone = character(0))
      call_back("on_eval_after_benchmark", self$callbacks, context)

      # aggregate performance scores
      private$.aggregated_performance = private$.benchmark_result$aggregate(self$measures, conditions = TRUE)[, c(self$codomain$target_ids, "warnings", "errors"), with = FALSE]

      # add runtime to evaluations
      time = map_dbl(private$.benchmark_result$resample_results$resample_result, function(rr) {
        sum(map_dbl(get_private(rr)$.data$learner_states(get_private(rr)$.view), function(state) state$train_time + state$predict_time))
      })
      set(private$.aggregated_performance, j = "runtime_learners", value = time)

      # add to hotstart stack
      if (self$allow_hotstart) {
        self$hotstart_stack$add(extract_benchmark_result_learners(private$.benchmark_result))
        if (!self$store_models) private$.benchmark_result$discard(models = TRUE)
      }

      call_back("on_eval_before_archive", self$callbacks, context)

      # store benchmark result in archive
      if (self$store_benchmark_result) {
        self$archive$benchmark_result$combine(private$.benchmark_result)
        set(private$.aggregated_performance, j = "uhash", value = private$.benchmark_result$uhashes)
      }

      # learner is not cloned anymore
      # restore default values
      self$learner$param_set$set_values(.values = self$default_values, .insert = FALSE)

      private$.aggregated_performance
    },

    .xss = NULL,
    .design = NULL,
    .benchmark_result = NULL,
    .aggregated_performance = NULL
  )
)
