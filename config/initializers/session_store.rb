Rails.application.config.session_store :cookie_store, key: '_walkin_session', secure: Rails.env.production?, expire_after: 6.months

#Rails.application.config.session_store :active_record_store, key: 'patient_id', secure: Rails.env.production?, expire_after: 1.year
# This saves sessions into DB, but is slower
#Rails.application.config.session_store :active_record_store, :key => '_walkin_session', secure: Rails.env.production?, expire_after: 1.year
