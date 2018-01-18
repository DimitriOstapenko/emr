csv_text = File.read(Rails.root.join('lib', 'seeds', 'diagfile_data.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

csv.each do |row|
  diag = Diagnosis.new   diag_code:  row['diag_code'],
		   	 diag_descr: row['diag_desc'],
		         prob_type:  row['prob_type']
  if diag.save		         
	  puts "#{diag.id} #{diag.diag_code} saved"
  else
	  puts 'Problem code: ', diag.inspect
  end

end

puts " #{Diagnosis.count} rows created in diagnoses table"
