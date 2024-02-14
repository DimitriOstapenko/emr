# resize images in current directory and put them into subdirectory [width]
# - creates directory named as width
# - smaller height files are padded with empty space
# - files other than 'jpg' are converted to 'jpg'
#
# ARG: width (px, preserve ratio)
#
require 'pathname'

width = ARGV[0] || '250'
abort "Usage: ruby resize.rb %width" unless (width && width.to_f > 0)  # 0 if not a number

height = (width.to_i / 1.5).to_s

curdir = Pathname.new(Dir.pwd)
target = curdir.join(width)

Dir.mkdir(target) unless File.exists?(target)
puts "** Target dir: #{target} width: #{width}px"

Pathname.glob("#{curdir}/*.*").sort.each do |entry|
  basename = entry.basename('.*')
  extname = entry.extname
  next if extname == '.rb'
  system "/usr/local/bin/convert '#{entry}' -resize #{width} -background white -extent #{width}x#{height} -gravity center '#{target}/#{basename}#{extname}'" 

  puts "'#{basename}#{extname}' -> './#{width}/#{basename}#{extname}"
end
