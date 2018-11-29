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

ActiveRecord::Schema.define(version: 2018_11_29_150615) do

  create_table "billings", force: :cascade do |t|
    t.integer "pat_id"
    t.string "doc_code"
    t.date "visit_date"
    t.integer "visit_id"
    t.string "proc_code"
    t.integer "proc_units"
    t.float "fee"
    t.string "btype"
    t.string "diag_code"
    t.string "status"
    t.float "amt_paid"
    t.date "paid_date"
    t.float "write_off"
    t.string "submit_file"
    t.integer "submit_year"
    t.string "remit_file"
    t.integer "remit_year"
    t.string "mohref"
    t.string "bill_prov"
    t.string "submit_user"
    t.datetime "submit_ts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "doc_id"
    t.index ["pat_id", "visit_date", "created_at"], name: "index_billings_on_pat_id_and_visit_date_and_created_at"
  end

  create_table "charts", force: :cascade do |t|
    t.integer "patient_id"
    t.integer "doctor_id"
    t.string "filename"
    t.integer "pages"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "claim_errors", force: :cascade do |t|
    t.string "code"
    t.text "descr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "claims", force: :cascade do |t|
    t.string "claim_no"
    t.string "provider_no"
    t.string "accounting_no"
    t.string "pat_lname"
    t.string "pat_fname"
    t.string "province"
    t.string "ohip_num"
    t.string "ohip_ver"
    t.string "pmt_pgm"
    t.string "moh_group_id"
    t.integer "visit_id"
    t.string "ra_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_paid"
    t.index ["accounting_no"], name: "index_claims_on_accounting_no"
    t.index ["claim_no"], name: "index_claims_on_claim_no"
  end

  create_table "daily_charts", force: :cascade do |t|
    t.string "filename"
    t.date "date"
    t.integer "pages"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_daily_charts_on_date"
    t.index ["filename"], name: "index_daily_charts_on_filename"
  end

  create_table "diagnoses", force: :cascade do |t|
    t.string "code"
    t.string "descr"
    t.string "prob_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.index ["code"], name: "index_diagnoses_on_code"
  end

  create_table "district_codes", force: :cascade do |t|
    t.string "code"
    t.string "place"
    t.string "m_or_t"
    t.string "county"
    t.string "lhin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dtype"
  end

  create_table "doctors", force: :cascade do |t|
    t.string "lname"
    t.string "fname"
    t.integer "cpso_num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bills"
    t.string "address"
    t.string "city"
    t.string "prov"
    t.string "postal"
    t.string "phone"
    t.string "mobile"
    t.string "licence_no"
    t.text "note"
    t.string "office"
    t.string "provider_no"
    t.string "group_no"
    t.string "specialty"
    t.string "email"
    t.string "doc_code"
    t.integer "percent_deduction"
    t.string "fax"
    t.integer "wsib_num", default: 0
    t.boolean "accepts_new_patients", default: false
    t.integer "district", default: 0
    t.index ["provider_no"], name: "index_doctors_on_provider_no"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "visit_id"
    t.string "document"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "description"
    t.integer "dtype"
    t.index ["visit_id"], name: "index_documents_on_visit_id"
  end

  create_table "drugs", force: :cascade do |t|
    t.string "name"
    t.string "dnum"
    t.string "strength"
    t.string "dose"
    t.string "freq"
    t.string "amount"
    t.string "status"
    t.string "generic"
    t.string "igcodes"
    t.string "format"
    t.string "route"
    t.integer "dur_cnt"
    t.string "dur_unit"
    t.integer "refills"
    t.integer "cost"
    t.string "lu_code"
    t.string "pharmacy"
    t.string "aliases"
    t.string "dtype"
    t.boolean "odb"
    t.string "filename"
    t.text "notes"
    t.text "instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "edt_files", force: :cascade do |t|
    t.integer "ftype"
    t.string "filename"
    t.date "upload_date"
    t.integer "lines"
    t.string "provider_no"
    t.string "group_no"
    t.integer "claims"
    t.float "total_amount"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "seq_no"
    t.integer "services"
    t.integer "doctors", default: 1
    t.integer "hcp_svcs"
    t.integer "rmb_svcs"
    t.boolean "processed", default: false
  end

  create_table "export_files", force: :cascade do |t|
    t.string "name"
    t.date "sdate"
    t.date "edate"
    t.integer "ttl_claims"
    t.integer "hcp_claims"
    t.integer "rmb_claims"
    t.integer "wcb_claims"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forms", force: :cascade do |t|
    t.string "name"
    t.string "descr"
    t.integer "ftype"
    t.string "filename"
    t.integer "format"
    t.date "eff_date"
    t.boolean "fillable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "form"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "patient_id"
    t.integer "billto"
    t.integer "visit_id"
    t.decimal "amount"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date"
    t.boolean "paid"
    t.string "filename"
    t.integer "doctor_id"
  end

  create_table "letters", force: :cascade do |t|
    t.string "title"
    t.integer "patient_id"
    t.integer "visit_id"
    t.integer "doctor_id"
    t.date "date"
    t.string "filename"
    t.string "to"
    t.string "address_to"
    t.text "body"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "from"
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
    t.string "ohip_ver"
    t.string "hin_prov"
    t.date "hin_expiry"
    t.string "pat_type"
    t.string "pharmacy"
    t.string "pharm_phone"
    t.text "notes"
    t.string "alt_contact_name"
    t.string "alt_contact_phone"
    t.string "email"
    t.string "chart_file"
    t.string "family_dr"
    t.string "mobile"
    t.string "lastmod_by"
    t.string "mname"
    t.date "entry_date"
    t.string "allergies"
    t.string "medications"
    t.string "maid_name"
    t.string "ifh_number"
    t.boolean "clinic_pat"
    t.index ["email"], name: "index_patients_on_email"
    t.index ["last_visit_date"], name: "index_patients_on_last_visit_date"
    t.index ["lname"], name: "index_patients_on_lname"
    t.index ["mobile"], name: "index_patients_on_mobile"
    t.index ["ohip_num"], name: "index_patients_on_ohip_num"
    t.index ["pat_type"], name: "index_patients_on_pat_type"
    t.index ["phone"], name: "index_patients_on_phone"
  end

  create_table "paystubs", force: :cascade do |t|
    t.integer "doc_id"
    t.integer "year"
    t.integer "month"
    t.integer "claims"
    t.integer "services"
    t.float "gross_amt", default: 0.0
    t.float "net_amt", default: 0.0
    t.float "ohip_amt", default: 0.0
    t.float "cash_amt", default: 0.0
    t.float "ifh_amt", default: 0.0
    t.float "monthly_premium_amt", default: 0.0
    t.float "hc_dep_amt", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "wcb_amt", default: 0.0
    t.string "filename"
    t.string "ra_file"
    t.date "date_paid"
    t.float "mho_deduction", default: 0.0
    t.float "clinic_deduction", default: 0.0
  end

  create_table "procedures", force: :cascade do |t|
    t.string "code"
    t.string "qcode"
    t.integer "ptype"
    t.string "descr"
    t.float "cost", default: 0.0
    t.integer "unit", default: 1
    t.boolean "fac_req", default: false
    t.boolean "adm_req", default: false
    t.boolean "diag_req", default: false
    t.boolean "ref_req", default: false
    t.integer "percent", default: 0
    t.date "eff_date"
    t.date "term_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.float "prov_fee", default: 0.0
    t.float "ass_fee", default: 0.0
    t.float "spec_fee", default: 0.0
    t.float "ana_fee", default: 0.0
    t.float "non_ana_fee", default: 0.0
    t.index ["code"], name: "index_procedures_on_code", unique: true
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.string "addr1"
    t.string "addr2"
    t.string "city"
    t.string "prov"
    t.string "country"
    t.string "postal"
    t.string "phone1"
    t.string "phone2"
    t.string "fax"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ra_accounts", force: :cascade do |t|
    t.string "tr_code"
    t.date "tr_date"
    t.integer "tr_amt"
    t.string "tr_msg"
    t.string "ra_file"
    t.date "date_paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_paid"], name: "index_ra_accounts_on_date_paid"
  end

  create_table "ra_errcodes", force: :cascade do |t|
    t.string "code"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ra_messages", force: :cascade do |t|
    t.text "msg_text"
    t.string "ra_file"
    t.date "date_paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group_no"
    t.string "payee_name"
    t.string "payee_addr"
    t.integer "amount"
    t.string "pay_method"
    t.string "bil_agent"
    t.index ["date_paid"], name: "index_ra_messages_on_date_paid"
  end

  create_table "referrals", force: :cascade do |t|
    t.integer "patient_id"
    t.integer "doctor_id"
    t.integer "visit_id"
    t.date "date"
    t.date "app_date"
    t.string "filename"
    t.integer "to_doctor_id"
    t.string "address_to"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "note"
    t.string "to_phone"
    t.string "to_fax"
    t.string "to_email"
  end

  create_table "reports", force: :cascade do |t|
    t.string "name"
    t.integer "doc_id"
    t.string "rtype"
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "sdate"
    t.date "edate"
    t.integer "timeframe"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "doctor_id"
    t.integer "dow"
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "weeks"
  end

  create_table "services", force: :cascade do |t|
    t.string "claim_no"
    t.integer "tr_type"
    t.date "svc_date"
    t.integer "units"
    t.string "svc_code"
    t.integer "amt_subm"
    t.integer "amt_paid"
    t.string "errcode"
    t.integer "claim_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_services_on_claim_id"
    t.index ["claim_no"], name: "index_services_on_claim_no"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "specialty_codes", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.integer "role"
    t.string "remember_digest"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vaccines", force: :cascade do |t|
    t.string "name"
    t.string "target"
    t.string "route"
    t.string "dose"
    t.string "din"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "visits", force: :cascade do |t|
    t.text "notes"
    t.string "diag_code"
    t.string "proc_code"
    t.integer "patient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "doc_id"
    t.integer "status"
    t.integer "duration"
    t.string "vis_type"
    t.string "entry_by"
    t.string "doc_code"
    t.datetime "entry_ts"
    t.float "fee", default: 0.0
    t.float "fee2", default: 0.0
    t.float "fee3", default: 0.0
    t.integer "units", default: 0
    t.integer "units2", default: 0
    t.integer "units3", default: 0
    t.float "fee4", default: 0.0
    t.integer "units4", default: 0
    t.string "proc_code2"
    t.string "proc_code3"
    t.string "proc_code4"
    t.integer "bil_type"
    t.integer "bil_type2"
    t.integer "bil_type3"
    t.integer "bil_type4"
    t.string "reason"
    t.integer "provider_id"
    t.integer "invoice_id"
    t.integer "temp"
    t.string "bp"
    t.integer "pulse"
    t.float "weight"
    t.string "export_file"
    t.decimal "amount", precision: 8, scale: 2
    t.integer "claim_id"
    t.string "billing_ref"
    t.string "document"
    t.index ["entry_ts"], name: "index_visits_on_entry_ts"
    t.index ["patient_id", "created_at"], name: "index_visits_on_patient_id_and_created_at"
    t.index ["patient_id"], name: "index_visits_on_patient_id"
  end

end
