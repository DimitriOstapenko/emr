CarrierWave.configure do |config|
#  if Rails.env.production?
#    config.fog_provider = 'fog/aws'
#    config.fog_credentials = {
#      provider:              'AWS',
#      aws_access_key_id:      S3_KEY_ID, 
#      aws_secret_access_key:  S3_KEY, 
#      region:                 S3_REGION 
#    }
#    config.fog_directory  =  S3_BUCKET
#    config.fog_public     = false
#    config.fog_use_ssl_for_aws = true 
#  else
    config.permissions = 0644
    config.storage = :file
#    config.asset_host = 'http://localhost:3000'
#  end
end

