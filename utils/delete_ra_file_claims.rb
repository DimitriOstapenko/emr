# Delete all claims, services, ra_messages and ra_accounts corresponding to specific RA file
#
# Letter, which identifies the file is passed as an arg
#
require_relative '../config/environment'

abort "Letter is required" unless letter = ARGV[0] 
path = EDT_PATH.join("P#{letter.upcase}#{GROUP_NO}.*")
path = Dir.glob(path).first rescue nil
base = File.basename(path)

puts "About to delete all claims, services, ra_messages and ra_accounts records corresponding to file #{path}"

claims = Claim.where(ra_file: base)
puts "Will delete #{claims.count} claims"

claims.all.each do | cl |
  cl.destroy	
end

puts "Will now delete messages and accounting records from ra_messages and ra_accounts tables"

msg = RaMessage.where(ra_file: base)
msg.all.each do |m|
  m.destroy
end

acc = RaAccount.where(ra_file: base)
acc.all.each do |a|
  a.destroy
end
