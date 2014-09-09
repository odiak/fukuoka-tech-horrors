# coding: utf-8

require "bundler"
Bundler.require

set :database, adapter: "sqlite3", database: "database.sqlite3"
