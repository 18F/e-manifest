require 'json'
require 'forwardable'

require 'rubygems'
require 'bundler'

Bundler.require

lib_dir = File.dirname(__FILE__) + "/lib"

require "#{lib_dir}/cdx"
require "#{lib_dir}/models/manifest"
