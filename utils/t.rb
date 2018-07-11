
content = "
HR4 claim header
HR5 1 A001A
HR5 2 A002A
HR5 3 A003A"

claim = ''
claim_count = 0
cl = {}
content.each_line do |str|
  hdr = str[0,3]
  case hdr
  when 'HR4'
          claim_count += 1
          claim = str
  when 'HR5'
	  (tmp,id,svc) = str.split(' ') 
          cl[claim] = {id: id, svc: svc}
  else
  end

end

puts cl.inspect
