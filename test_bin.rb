require "./lib/stl_parser.rb"
puts "======================Testing Binary=============================="
parsed = STLParser.new
parsed.process(Dir.pwd+'/Tower x2.stl')

puts 'Volume:' + parsed.volume.to_s
puts 'Area:' + parsed.area.to_s
puts 'X dimensions:' + parsed.x_dimensions.to_s
puts 'Y dimensions:' + parsed.y_dimensions.to_s
puts 'Z dimensions:' + parsed.z_dimensions.to_s

parsed = STLParser.new
parsed.process(Dir.pwd+'/Pin x8.stl')
puts ""
puts 'Volume:' + parsed.volume.to_s
puts 'Area:' + parsed.area.to_s
puts 'X dimensions:' + parsed.x_dimensions.to_s
puts 'Y dimensions:' + parsed.y_dimensions.to_s
puts 'Z dimensions:' + parsed.z_dimensions.to_s