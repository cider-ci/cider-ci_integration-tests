#!/usr/bin/env ruby

require "pry"
require "active_support/all"
require "json"
require 'yaml'

PROJECT_DIR = Pathname.new(__FILE__).expand_path.join("../../../..")
features_json = IO.read PROJECT_DIR.join("tmp/features.json")
features = JSON.parse(features_json).with_indifferent_access

# name must be unique but they are not: append index
$name_id = {}
def set_name(example)
  name = example[:full_description].remove(example[:description]).strip
  $name_id[name] = 1 + ($name_id[name] || 0)
  example[:name] = name + format(" %02d", $name_id[name])
  example
end


mapped = features[:examples].map { |example|
  set_name(example)
}.map { |example|
  [ example[:id],
    {'name': example['name'],
     environment_variables: {
       FEATURE_NAME: example[:name],
       FEATURE: example[:id],}.stringify_keys}.stringify_keys]
}


File.open(PROJECT_DIR.join("cider-ci", "generators", "feature-tasks.yml"), "w") do |f|
  f.write(mapped.to_h.stringify_keys.to_yaml)
end
