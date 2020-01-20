# Join 2 pdf files, create backup copy of the original
require_relative '../config/environment'

fn1 = '/Users/dmitri/Desktop/GUL,SAADIA.pdf' 
dir_name = File.dirname(fn1)
base_name = File.basename(fn1,'.pdf')
fn2 = '/Users/dmitri/Desktop/41380.pdf' 
fn3 = "#{dir_name}/#{base_name}.bak"

File.rename(fn1, fn3) 
#puts "#{dir_name}/#{base_name}.bak"

(CombinePDF.load(fn3) << CombinePDF.load(fn2)).save(fn1)
