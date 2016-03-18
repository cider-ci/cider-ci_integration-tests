require 'spec_helper'
require 'features/job-spec_validation_shared'

describe 'Validating a job with a bogus key', type: :feature do
  let :job_name do
    'Job with a bogus key'
  end
  let :cider_ci_config do <<-YAML.strip_heredoc
      jobs:
        test-job:
          name: #{job_name}
          bogus: whatever
          YAML
  end
  custom_expectations = <<-RB.strip_heredoc
    expect(find(".alert")).to have_content \
      /Error: Validation Error - Unknown Property/

    expect(find(".alert")).to have_content \
      /test-job.*includes.*unknown property.*bogus/
  RB
  include_examples :generic_job_spec_validation_fail, custom_expectations
end

describe 'Validating contexts and contexts', type: :feature do

  describe "a main-context with a bogus key" do
    let :job_name do
      'Job with a main-context with a bogus key'
    end
    let :cider_ci_config do <<-YAML.strip_heredoc
      jobs:
        test:
          name: #{job_name}
          context:
            bogus: whatever
          YAML
    end
    custom_expectations = <<-RB.strip_heredoc
      expect(find(".alert")).to \
        have_content /test.*context.*bogus/
    RB
    include_examples :generic_job_spec_validation_fail, custom_expectations
  end

  describe "a subcontext with a bogus key" do
    let :job_name do
      'Job with a subcontext with a bogus key'
    end
    let :cider_ci_config do <<-YAML.strip_heredoc
      jobs:
        test:
          name: #{job_name}
          context:
            contexts:
              some-subcontext:
                bogus: whatever
          YAML
    end
    custom_expectations = <<-RB.strip_heredoc
      expect(find(".alert")).to \
        have_content /test.*context.*contexts.*some-subcontext.*bogus/
    RB
    include_examples :generic_job_spec_validation_fail, custom_expectations
  end
end

