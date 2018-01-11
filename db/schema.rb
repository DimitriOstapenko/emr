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

ActiveRecord::Schema.define(version: 20180111024951) do

  create_table "doctors", force: :cascade do |t|
    t.string "lname"
    t.string "fname"
    t.integer "cpso_num"
    t.integer "billing_num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string "lname"
    t.string "fname"
    t.string "ohip_num"
    t.date "dob"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sex"
    t.date "last_visit_date"
    t.string "addr"
    t.string "city"
    t.string "postal"
    t.string "prov"
    t.string "country"
    t.index ["last_visit_date"], name: "index_patients_on_last_visit_date"
    t.index ["lname"], name: "index_patients_on_lname"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.datetime "date"
    t.text "notes"
    t.decimal "diag_code"
    t.string "proc_code"
    t.integer "patient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "doc_id"
    t.index ["patient_id", "created_at"], name: "index_visits_on_patient_id_and_created_at"
    t.index ["patient_id"], name: "index_visits_on_patient_id"
  end

end
