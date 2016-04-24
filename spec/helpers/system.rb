require 'open3'

module Helpers
  module System
    class << self
      def exec! cmd
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          exit_status = wait_thr.value
          unless exit_status.success?
            abort stderr.read
          else
            stdout.read.strip
          end
        end
      end
    end
  end
end

