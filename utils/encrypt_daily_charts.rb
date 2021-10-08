#  Encrypt all charts with password
#
#  Requires libpodofo-utils
#
require_relative '../config/environment'

pass = "StoneyCreek2021"
dir  = Rails.root.join(CHARTS_PATH, 'Daily')
charts_count = 0

Dir.glob( "#{dir}**/*/*.pdf" ) do |path| 
	basename = File.basename(path)
        charts_count +=1

        system "podofoencrypt --rc4v2 -u #{pass} -o #{pass} #{path} #{Rails.root.join('pcharts', 'Daily', basename)}"
end

puts "processed #{charts_count} Daily charts"


