class Repository < Sequel::Model
end

FactoryBot.define do

  factory :demo_repository, class: Repository do
    name {'Demo Project'}
    git_url { 'file://' + File.expand_path('../demo-project-bash', __FILE__) }
    remote_fetch_interval { '1 Second' }
    branch_trigger_max_commit_age { '100 years' }
    public_view_permission { true }

    before(:create) do |repo|
      repo
    end
  end

end
