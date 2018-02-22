require 'date'

fname = DateTime.now.to_s + '.csv'
begin
  file = File.open(fname, 'w') 
  file.write("line of text")
  rescue IOError => e
    #some error occur, dir not writable etc.
  ensure
    file.close unless file.nil?
end
