require 'spec_helper'
require 'features/job-spec_validation_shared'

describe "Validating task and task_defaults" do
  describe "a task with a bogus key " do
    let :job_name do
      'Job with a bogus key in the task'
    end
    let :cider_ci_config do <<-YAML.strip_heredoc
      jobs:
        test:
          name: #{job_name}
          context:
            tasks:
              task_with_a_bogus_key:
                bogus: whatever
      YAML
    end
    custom_expectations = <<-RB.strip_heredoc
      expect(find(".alert")).to have_content(/task_with_a_bogus_key/)
    RB
    include_examples :generic_job_spec_validation_fail, custom_expectations
  end

  describe "task_defaults with a bogus key " do
    let :job_name do
      'Job with a bogus key in the task'
    end
    let :cider_ci_config do <<-YAML.strip_heredoc
      jobs:
        test:
          name: #{job_name}
          context:
            task_defaults:
              bogus: whatever
            tasks: {}
      YAML
    end
    include_examples :generic_job_spec_validation_fail
  end

end
