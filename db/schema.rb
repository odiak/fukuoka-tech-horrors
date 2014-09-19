# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140919094025) do

  create_table "stories", force: true do |t|
    t.string   "title",       default: "", null: false
    t.text     "body",        default: "", null: false
    t.integer  "author_id",                null: false
    t.integer  "votes_count", default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "uid",                                 null: false
    t.string   "name",                default: "",    null: false
    t.string   "screen_name",                         null: false
    t.string   "access_token",                        null: false
    t.string   "access_token_secret",                 null: false
    t.string   "icon",                default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",            default: false, null: false
  end

  add_index "users", ["uid"], name: "index_users_on_uid", unique: true

  create_table "votings", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "story_id",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count",      default: 1, null: false
  end

  add_index "votings", ["user_id", "story_id"], name: "index_votings_on_user_id_and_story_id", unique: true

end
