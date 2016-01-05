require 'json'
require 'forwardable'
require 'logger'

require 'rubygems'
require 'bundler'

Bundler.require

lib_dir = File.dirname(__FILE__)
Dir.glob('config/*.rb').each { |r| load r}

require "#{lib_dir}/connect_ar"
require "#{lib_dir}/cdx"
require "#{lib_dir}/workers/indexer_worker"
require "#{lib_dir}/models/manifest"
