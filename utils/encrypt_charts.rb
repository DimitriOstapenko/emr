#  Encrypt all charts with password
#  Requires libpodofo-utils
#
require_relative '../config/environment'

pass = "StoneyCreek2021"
dir  = CHARTS_PATH
charts_count = 0

Dir.glob( "#{dir}/*.pdf" ) do |path| 
	basename = File.basename(path)
        next unless basename =~ /^\d+\.pdf$/
        charts_count +=1
        system "podofoencrypt --rc4v2 -u #{pass} -o #{pass} #{path} #{Rails.root.join('pcharts', basename)}"
end
puts "processed #{charts_count} charts"


