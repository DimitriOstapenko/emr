#
#
#

#Rails.application.config.session_store :cookie_store, key: '_walkin_session', secure: Rails.env.production?, expire_after: 1.day
Rails.application.config.session_store :active_record_store, :key => '_walkin_session', secure: Rails.env.production?, expire_after: 1.day
