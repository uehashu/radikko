# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_30_154759) do

  create_table "areas", id: false, force: :cascade do |t|
    t.string "area_id"
    t.string "area_name"
    t.string "area_name_kana"
    t.index ["area_id"], name: "index_areas_on_area_id", unique: true
  end

  create_table "configures", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_configures_on_key", unique: true
  end

  create_table "programs", force: :cascade do |t|
    t.string "station_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "duration_sec"
    t.string "title"
    t.string "subtitle"
    t.string "performers"
    t.text "description"
    t.string "reserved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recordings", force: :cascade do |t|
    t.integer "area_id"
    t.string "station_id"
    t.datetime "start_datetime"
    t.integer "recording_second"
    t.string "title"
    t.string "filename"
    t.string "job_id"
    t.boolean "is_recorded"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stations", force: :cascade do |t|
    t.string "station_id"
    t.string "station_name"
    t.string "station_name_ascii"
    t.string "area_id"
  end

end
