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

ActiveRecord::Schema.define(version: 20150314023409) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "monitor_events", force: :cascade do |t|
    t.integer  "monitor_incident_id"
    t.string   "status"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.datetime "triggered_at",        null: false
  end

  add_index "monitor_events", ["monitor_incident_id"], name: "index_monitor_events_on_monitor_incident_id", using: :btree

  create_table "monitor_incidents", force: :cascade do |t|
    t.integer  "web_service_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "monitor_incidents", ["web_service_id"], name: "index_monitor_incidents_on_web_service_id", using: :btree

  create_table "web_services", force: :cascade do |t|
    t.string   "pingometer_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_foreign_key "monitor_events", "monitor_incidents"
  add_foreign_key "monitor_incidents", "web_services"
end
