require 'rspec/expectations'
require 'open3'

RSpec::Matchers.define :pass_execution do
  match do |cmd|
    stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
    stdin.close
    @res = stdout.read
    @res << stderr.read
    (@val = wait_thr.value) == 0
  end
  failure_message do |cmd|
    "Expected that cmd `#{cmd}` would exit with 0" \
    " but exited with #{@val} and output: '#{@res}'."
  end
end
