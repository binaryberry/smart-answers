require_relative '../test_helper'
require_relative '../helpers/i18n_test_helper'

require 'fixtures/graph_presenter_test/graph'
require 'fixtures/graph_presenter_test/missing_transition'

module SmartAnswer
  class GraphPresenterTest < ActiveSupport::TestCase
    include I18nTestHelper

    setup do
      use_only_translation_file!(fixture_file('graph_presenter_test/graph.yml'))
      @flow = SmartAnswer::GraphFlow.build
      @presenter = GraphPresenter.new(@flow)
    end

    teardown do
      reset_translation_files!
    end

    test "presents labels of simple graph" do
      expected_labels = {
        q1?: "MultipleChoice\n-\nWhat is the answer to q1?\n\n( ) yes\n( ) no",
        q2?: "MultipleChoice\n-\nWhat is the answer to q2?\n\n( ) a\n( ) b",
        done_a: "Outcome\n-\nDone A",
        done_b: "Outcome\n-\nDone B"
      }

      assert_equal expected_labels, @presenter.labels
    end

    test "outcome node label falls back to node name if title missing" do
      using_only_translation_file(fixture_file('graph_presenter_test/graph_missing_outcome_label.yml')) do
        assert_equal "Outcome\n-\ndone_a", @presenter.labels[:done_a]
        assert_equal "Outcome\n-\ndone_b", @presenter.labels[:done_b]
      end
    end

    test "presents adjacency_list of simple graph" do
      expected_adjacency_list = {
        q1?: [[:q2?, "yes"], [:q2?, "no"]],
        q2?: [[:done_a, ''], [:done_b, '']],
        done_a: [],
        done_b: []
      }

      assert_equal expected_adjacency_list, @presenter.adjacency_list
    end

    test "indicates does not define transitions in a way which can be visualised" do
      p = GraphPresenter.new(SmartAnswer::GraphFlow.build)
      assert p.visualisable?, "'graph' should be visualisable"

      p = GraphPresenter.new(SmartAnswer::MissingTransitionFlow.build)
      refute p.visualisable?, "'missing_transition' should not be visualisable"
    end
  end
end
