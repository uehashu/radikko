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

ActiveRecord::Schema.define(version: 20150618115305) do

  create_table "areas", id: false, force: :cascade do |t|
    t.string "area_id"
    t.string "area_name"
    t.string "area_name_kana"
  end

  add_index "areas", ["area_id"], name: "index_areas_on_area_id", unique: true

  create_table "configures", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "configures", ["key"], name: "index_configures_on_key", unique: true

  create_table "programs", force: :cascade do |t|
    t.string   "station_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "duration_sec"
    t.string   "title"
    t.string   "subtitle"
    t.string   "performers"
    t.text     "description"
    t.string   "reserved"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "stations", force: :cascade do |t|
    t.string "station_id"
    t.string "station_name"
    t.string "station_name_ascii"
    t.string "area_id"
  end

  add_index "stations", ["station_id"], name: "index_stations_on_station_id", unique: true

end
