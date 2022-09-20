# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Patches GraphQL::Execution::Multiplex to support compiled queries
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Layout/IndentationWidth
      # rubocop:disable Metrics/PerceivedComplexity, Metrics/ModuleLength, Metrics/LineLength
      # rubocop:disable Metrics/BlockLength, Style/BracesAroundHashParameters, Style/CommentAnnotation
      # rubocop:disable Naming/RescuedExceptionsVariableName, Layout/SpaceInsideHashLiteralBraces
      # rubocop:disable Lint/ShadowingOuterLocalVariable, Style/BlockDelimiters, Metrics/MethodLength
      # rubocop:disable Style/Next, Layout/ElseAlignment, Layout/EndAlignment, Lint/RescueException
      module InterpreterPatch
        # This method is fully copied from the gem because I didn't find a way to patch it. In future we will
        # need to keep it in sync and migrate the monkey patch to newer versions of the file.
        def run_all(schema, query_options, context: {}, max_complexity: schema.max_complexity)
          queries = query_options.map do |opts|
            case opts
            when Hash
              GraphQL::Query.new(schema, nil, **opts)
            when GraphQL::Query
              opts
            else
              raise "Expected Hash or GraphQL::Query, not #{opts.class} (#{opts.inspect})"
            end
          end

          multiplex = Execution::Multiplex.new(schema: schema, queries: queries, context: context, max_complexity: max_complexity)
          multiplex.trace("execute_multiplex", { multiplex: multiplex }) do
            schema = multiplex.schema
            queries = multiplex.queries
            query_instrumenters = schema.instrumenters[:query]
            multiplex_instrumenters = schema.instrumenters[:multiplex]

            # First, run multiplex instrumentation, then query instrumentation for each query
            call_hooks(multiplex_instrumenters, multiplex, :before_multiplex, :after_multiplex) do
              each_query_call_hooks(query_instrumenters, queries) do
                schema = multiplex.schema
                multiplex_analyzers = schema.multiplex_analyzers
                queries = multiplex.queries
                if multiplex.max_complexity
                  multiplex_analyzers += [GraphQL::Analysis::AST::MaxQueryComplexity]
                end

                schema.analysis_engine.analyze_multiplex(multiplex, multiplex_analyzers)
                begin
                  # Since this is basically the batching context,
                  # share it for a whole multiplex
                  multiplex.context[:interpreter_instance] ||= multiplex.schema.query_execution_strategy.new
                  # Do as much eager evaluation of the query as possible
                  results = []
                  queries.each_with_index do |query, idx|
                    multiplex.dataloader.append_job {
                      operation = query.selected_operation
                      result =
                        # MONKEY PATCH START
                        if query.persisted_query_not_found?
                          query.context.errors.clear
                          query.context.errors << GraphQL::ExecutionError.new("PersistedQueryNotFound")
                          singleton_class::NO_OPERATION
                        # MONKEY PATCH END
                        elsif operation.nil? || !query.valid? || query.context.errors.any?
                          singleton_class::NO_OPERATION
                        else
                          begin
                            # Although queries in a multiplex _share_ an Interpreter instance,
                            # they also have another item of state, which is private to that query
                            # in particular, assign it here:
                            runtime = GraphQL::Execution::Interpreter::Runtime.new(query: query)
                            query.context.namespace(:interpreter)[:runtime] = runtime

                            query.trace("execute_query", {query: query}) do
                              runtime.run_eager
                            end
                          rescue GraphQL::ExecutionError => err
                            query.context.errors << err
                            singleton_class::NO_OPERATION
                          end
                        end
                      results[idx] = result
                    }
                  end

                  multiplex.dataloader.run

                  # Then, work through lazy results in a breadth-first way
                  multiplex.dataloader.append_job {
                    tracer = multiplex
                    query = multiplex.queries.length == 1 ? multiplex.queries[0] : nil
                    queries = multiplex ? multiplex.queries : [query]
                    final_values = queries.map do |query|
                      runtime = query.context.namespace(:interpreter)[:runtime]
                      # it might not be present if the query has an error
                      runtime ? runtime.final_result : nil
                    end
                    final_values.compact!
                    tracer.trace("execute_query_lazy", {multiplex: multiplex, query: query}) do
                      GraphQL::Execution::Interpreter::Resolve.resolve_all(final_values, multiplex.dataloader)
                    end
                    queries.each do |query|
                      runtime = query.context.namespace(:interpreter)[:runtime]
                      if runtime
                        runtime.delete_interpreter_context(:current_path)
                        runtime.delete_interpreter_context(:current_field)
                        runtime.delete_interpreter_context(:current_object)
                        runtime.delete_interpreter_context(:current_arguments)
                      end
                    end
                  }
                  multiplex.dataloader.run

                  # Then, find all errors and assign the result to the query object
                  results.each_with_index do |data_result, idx|
                    query = queries[idx]
                    # Assign the result so that it can be accessed in instrumentation
                    query.result_values = if data_result.equal?(singleton_class::NO_OPERATION)
                      if !query.valid? || query.context.errors.any?
                        # A bit weird, but `Query#static_errors` _includes_ `query.context.errors`
                        { "errors" => query.static_errors.map(&:to_h) }
                      else
                        data_result
                      end
                    else
                      result = {
                        "data" => query.context.namespace(:interpreter)[:runtime].final_result
                      }

                      if query.context.errors.any?
                        error_result = query.context.errors.map(&:to_h)
                        result["errors"] = error_result
                      end

                      result
                    end
                    if query.context.namespace?(:__query_result_extensions__)
                      query.result_values["extensions"] = query.context.namespace(:__query_result_extensions__)
                    end
                    # Get the Query::Result, not the Hash
                    results[idx] = query.result
                  end

                  results
                rescue Exception
                  # TODO rescue at a higher level so it will catch errors in analysis, too
                  # Assign values here so that the query's `@executed` becomes true
                  queries.map { |q| q.result_values ||= {} }
                  raise
                end
              end
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Layout/IndentationWidth
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/ModuleLength, Metrics/LineLength
    # rubocop:enable Metrics/BlockLength, Style/BracesAroundHashParameters, Style/CommentAnnotation
    # rubocop:enable Naming/RescuedExceptionsVariableName, Layout/SpaceInsideHashLiteralBraces
    # rubocop:enable Lint/ShadowingOuterLocalVariable, Style/BlockDelimiters, Metrics/MethodLength
    # rubocop:enable Style/Next, Layout/ElseAlignment, Layout/EndAlignment, Lint/RescueException
  end
end
