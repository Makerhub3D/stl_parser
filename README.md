# STL Parser

A ruby gem for calculating the bounding box, surface area and volume for an STL file.


## Installation
bundle install stl_parser

## Usage

	require "stl_parser"
	parser = STLParser.new

	# path: URL or local file path
	parser.process(path)
	
	volume = parser.volume
	area = parser.area
	x_dimensions = parser.x_dimensions
	y_dimensions = parser.y_dimensions
	z_dimensions = parser.z_dimensions

#Publishing
Update the version in stl_parser.gemspec
gem build stl_parser.gemspec
gem push stl_parser-x.x.x.gem
