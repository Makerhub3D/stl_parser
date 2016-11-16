class STLParser

  def resetVariables()
    @normals = []
    @points = []
    @triangles = []
    @fb = [] # debug list
    @volume = 0
    @area = 0
    @max_x = nil
    @max_y = nil
    @max_z = nil
    @min_x = nil
    @min_y = nil
    @min_z = nil
    @num_triangles = 0
    @file_type = :binary
  end

  # Calculate volume for the 3D mesh using Tetrahedron volume
  def signedVolumeOfTriangle(p1, p2, p3)
    v321 = p3[0]*p2[1]*p1[2]
    v231 = p2[0]*p3[1]*p1[2]
    v312 = p3[0]*p1[1]*p2[2]
    v132 = p1[0]*p3[1]*p2[2]
    v213 = p2[0]*p1[1]*p3[2]
    v123 = p1[0]*p2[1]*p3[2]
    return (1.0/6.0)*(-v321 + v231 + v312 - v132 - v213 + v123)
  end

  # Calculate area of the triangle
  def signedAreaOfTriangle(p1, p2, p3)
    # Update the area by adding
    a = p3.zip(p1).map { |x, y| x - y }
    b = p3.zip(p2).map { |x, y| x - y }

    cx = a[1]*b[2] - a[2]*b[1]
    cy = a[2]*b[0] - a[0]*b[2]
    cz = a[0]*b[1] - a[1]*b[0]

    c = [cx, cy, cz]

    return Math.sqrt(c[0]*c[0] + c[1]*c[1] + c[2]*c[2]).abs/2
  end

  def custom_unpack(sig, num_lines)
    str = @f.read(num_lines)
    @fb.push(str)
    return str.unpack(sig) if str
    return 0
  end

  def read_triangle()
    if(@file_type === :binary)
      n  = custom_unpack("eee", 12)
      p1 = custom_unpack("eee", 12)
      p2 = custom_unpack("eee", 12)
      p3 = custom_unpack("eee", 12)

      # To get past the space filler
      @f.read(2)
    else
      temp = @f.gets
      unless temp.include? 'endsolid'
        # Get the normal
        temp.sub!(/facet normal/, '').strip!
        n  = temp.split(' ').map{ |num| num.to_f }

        # get past 'outer loop'
        @f.gets

        # get vertex one
        temp = @f.gets
        p1 = temp.sub(/vertex/, '').split(' ').map{ |num| num.to_f }

        # get vertex two
        temp = @f.gets
        p2 = temp.sub(/vertex/, '').split(' ').map{ |num| num.to_f }

        # get vertex three
        temp = @f.gets
        p3 = temp.sub(/vertex/, '').split(' ').map{ |num| num.to_f }

        # Get past endloop
        @f.gets
        # Get past endfacet
        temp = @f.gets
      end
    end
    unless @f.eof
      @min_x = p1[0] if(@min_x.nil? || @min_x > p1[0])
      @min_x = p2[0] if(@min_x.nil? || @min_x > p2[0])
      @min_x = p3[0] if(@min_x.nil? || @min_x > p3[0])

      @min_y = p1[1] if(@min_y.nil? || @min_y > p1[1])
      @min_y = p2[1] if(@min_y.nil? || @min_y > p2[1])
      @min_y = p3[1] if(@min_y.nil? || @min_y > p3[1])

      @min_z = p1[2] if(@min_z.nil? || @min_z > p1[2])
      @min_z = p2[2] if(@min_z.nil? || @min_z > p2[2])
      @min_z = p3[2] if(@min_z.nil? || @min_z > p3[2])

      @max_x = p1[0] if(@max_x.nil? || @max_x < p1[0])
      @max_x = p2[0] if(@max_x.nil? || @max_x < p2[0])
      @max_x = p3[0] if(@max_x.nil? || @max_x < p3[0])

      @max_y = p1[1] if(@max_y.nil? || @max_y < p1[1])
      @max_y = p2[1] if(@max_y.nil? || @max_y < p2[1])
      @max_y = p3[1] if(@max_y.nil? || @max_y < p3[1])

      @max_z = p1[2] if(@max_z.nil? || @max_z < p1[2])
      @max_z = p2[2] if(@max_z.nil? || @max_z < p2[2])
      @max_z = p3[2] if(@max_z.nil? || @max_z < p3[2])

      @normals.push(n)
      l = @points.length
      @points.push(p1)
      @points.push(p2)
      @points.push(p3)
      @triangles.push(l)

      # Update the volume
      @volume += signedVolumeOfTriangle(p1,p2,p3)

      # Update the area
      @area += signedAreaOfTriangle(p1,p2,p3)
    end
  end

  def read_length()
    length = @f.read(4).unpack("s")
    return length[0]
  end

  def read_binary_header()
    @f.seek(@f.tell()+80)
  end

  def volume()
    @volume.abs
  end

  def area()
    @area.abs
  end

  def triangles()
    @num_triangles
  end

  def x_dimensions()
    @max_x - @min_x
  end

  def y_dimensions()
    @max_y - @min_y
  end

  def z_dimensions()
    @max_z - @min_z
  end

  def process(infilename)
    resetVariables()

    @f = File.open(infilename, "rb")

    # Set the file type to ascii if needed
    binary_found = false
    @f.each_line do |line|
      if(@f.gets.ascii_only? == false)
        binary_found = true
        break
      end
    end

    unless(binary_found)
      @file_type = :ascii
    end

    # Go back to beginning of the file
    @f.seek(0)

    # Get past the header info that we don't care about
    if(@file_type === :binary)
      read_binary_header()
      @num_triangles = read_length()
    else
      @f.gets
    end

    # Keep repeating until the end of the file is reached to calculate values
    while @f.eof === false do
      read_triangle()
    end

    # Close the file
    @f.close
  end
end
