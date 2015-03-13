module Minitest
  module Reporters
    class AwesomeReporter < DefaultReporter

      def initialize(options = {})
        super
        @slow_threshold = options.fetch(:slow_threshold, nil)
      end

      def record_pass(test)
        if @slow_threshold.nil? || test.time <= @slow_threshold
          super
        else
          color_up('O', '0;36')
        end
      end

      def color_up(string, color)
          color? ? "\e\[#{ color }m#{ string }#{ ANSI::Code::ENDCODE }" : string
      end

    end
  end
end
