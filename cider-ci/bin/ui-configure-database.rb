#!/usr/bin/env ruby
require 'yaml'

config = \
  { 'test' =>
    { 'adapter' => 'postgresql',
      'encoding' => 'unicode',
      'host' => 'localhost',
      'pool' => 3,
      'port' => Integer(ENV['PGPORT']),
      'username' => ENV['PGUSER'],
      'password' =>  ENV['PGPASSWORD'],
      'database' => "cider-ci_test_#{ENV['CIDER_CI_TRIAL_ID']}"}}
File.open('user-interface/config/database.yml','w') { |file| file.write config.to_yaml }

