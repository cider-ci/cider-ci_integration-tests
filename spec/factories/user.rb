class User < Sequel::Model
  attr_accessor :password
  attr_accessor :firstname
  attr_accessor :lastname
  many_to_many :groups, join_table: :groups_users
  one_to_many :email_addresses
end

FactoryBot.define do
  factory :user do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.unique.last_name }
    name { firstname + ' ' + lastname }
    password { Faker::Internet.password() }
    is_admin { is_system_admin }

    after(:create) do |user|
      pw_hash = database["SELECT crypt(#{database.literal(user.password)}, " \
                         "gen_salt('bf')) AS pw_hash"].first[:pw_hash]
      user.password_digest = pw_hash
      user.save

      database[:email_addresses].insert(
        user_id: user.id,
        primary: true,
        email_address: (user.firstname + '.' +
                        user.lastname + '@' +
                        Faker::Internet.domain_name))

    end

    factory :admin do
      is_admin { true }
    end

  end
end
