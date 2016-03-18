require 'spec_helper'
require 'features/aggregate-state_satisfy-any_shared'


feature 'Aggregate State Feature', type: :feature do
  include_examples :job_stayes_passed_when_last_trial_failed,
                   'Aggregate State with Explicit `satisfy-any`'
end
