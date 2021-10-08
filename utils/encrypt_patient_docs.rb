#  Encrypt all patient charts with password
#
#  Requires libpodofo-utils
#
require_relative '../config/environment'

pass = "StoneyCreek2021"
dir  = Rails.root.join('ppatient_doc')
docs_count = 0

Dir.glob( "#{dir}**/*/*.pdf" ) do |path| 
	basename = File.basename(path)
        docs_count +=1

        system "podofoencrypt --rc4v2 -u #{pass} -o #{pass} #{path} #{path}_"
        system "mv #{path}_ #{path}"
end

puts "processed #{docs_count} patient docs"


