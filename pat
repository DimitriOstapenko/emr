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

ohip_ver:string hin_prov:string hin_expiry:date pat_type:string pharmacy:string pharm_phone:string file_no:string notes:text alt_contact_name:string alt_contact_phone:string email:string chart_file:string family_dr:string mobile:string
