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

ActiveRecord::Schema.define(version: 20171018215115) do

  create_table "queued_slack_users", force: :cascade do |t|
    t.string "slack_user_name"
    t.string "slack_user_id"
    t.integer "thing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "things", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "in_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "usage_events", force: :cascade do |t|
    t.integer "thing_id_id"
    t.string "event_type", limit: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_usage_events_on_event_type"
    t.index ["thing_id_id"], name: "index_usage_events_on_thing_id_id"
  end

end
