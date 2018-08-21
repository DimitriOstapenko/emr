CarrierWave.configure do |config|
  if Rails.env.production?
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     'AKIAJ7HZWQRXMH77F4TA',  #ENV['S3_KEY'],
      aws_secret_access_key: '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', #ENV['S3_SECRET'],
      region:                'us-east-1' #ENV['S3_REGION'],
    }
    config.fog_directory  =  'scwalkin' #ENV['S3_BUCKET']
    config.fog_public     = false
    config.fog_use_ssl_for_aws = true 
  else
    config.storage = :file
    config.asset_host = 'http://localhost:3000'
  end
end

