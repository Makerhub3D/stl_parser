# STL Parser

A ruby gem for calculating the bounding box and volume for an STL file.


## Installation
bundle install stl_parser

## Usage

	require "stl_parser"
	parser = STLParser.new

	# path: URL or local file path
	parser.process(path)
	
	volume = parser.volume
	x_dimensions = parser.x_dimensions
	y_dimensions = parser.y_dimensions
	z_dimensions = parser.z_dimensions
