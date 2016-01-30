class STLParser

  def resetVariables()
    @normals = []
    @points = []
    @triangles = []
    @bytecount = []
    @fb = [] # debug list
    @volume = 0
    @max_x = 0
    @max_y = 0
    @max_z = 0
    @min_x = 0
    @min_y = 0
    @min_z = 0
    @num_triangles = 0
    @file_type = :binary
  end

  # Calculate volume fo the 3D mesh using Tetrahedron volume
  def signedVolumeOfTriangle(p1, p2, p3)
    v321 = p3[0]*p2[1]*p1[2]
    v231 = p2[0]*p3[1]*p1[2]
    v312 = p3[0]*p1[1]*p2[2]
    v132 = p1[0]*p3[1]*p2[2]
    v213 = p2[0]*p1[1]*p3[2]
    v123 = p1[0]*p2[1]*p3[2]
    return (1.0/6.0)*(-v321 + v231 + v312 - v132 - v213 + v123)
  end

  def custom_unpack(sig, num_lines)
    str = @f.read(num_lines)
    @fb.push(str)
    return str.unpack(sig)
  end

  def read_triangle()
    if(@file_type === :binary)
      n  = custom_unpack("eee", 12)
      p1 = custom_unpack("eee", 12)
      p2 = custom_unpack("eee", 12)
      p3 = custom_unpack("eee", 12)
      b  = custom_unpack("S!", 2)
    else
      n  = 0
      p1 = 0
      p2 = 0
      p3 = 0
      b  = 0
    end

    @min_x = p1[0] if(@min_x > p1[0])
    @min_x = p2[0] if(@min_x > p2[0]) 
    @min_x = p3[0] if(@min_x > p3[0]) 

    @min_y = p1[1] if(@min_y > p1[1]) 
    @min_y = p2[1] if(@min_y > p2[1]) 
    @min_y = p3[1] if(@min_y > p3[1]) 

    @min_z = p2[2] if(@min_z > p2[2]) 
    @min_z = p2[2] if(@min_z > p2[2]) 
    @min_z = p3[2] if(@min_z > p3[2]) 

    @max_x = p1[0] if(@max_x < p1[0])
    @max_x = p2[0] if(@max_x < p2[0]) 
    @max_x = p3[0] if(@max_x < p3[0]) 

    @max_y = p1[1] if(@max_y < p1[1]) 
    @max_y = p2[1] if(@max_y < p2[1]) 
    @max_y = p3[1] if(@max_y < p3[1]) 

    @max_z = p2[2] if(@max_z < p2[2]) 
    @max_z = p2[2] if(@max_z < p2[2]) 
    @max_z = p3[2] if(@max_z < p3[2]) 

    @normals.push(n)
    l = @points.length
    @points.push(p1)
    @points.push(p2)
    @points.push(p3)
    @triangles.push(l)
    @bytecount.push(b[0])
    return signedVolumeOfTriangle(p1,p2,p3)
  end

  def read_length()
    length = @f.read(4).unpack("s")
    return length[0]
  end

  def read_header()
    @f.seek(@f.tell()+80)
  end

  def volume()
    @volume
  end

  def triangles()
    @num_triangles
  end

  def x_dimensions()
    (@max_x - @min_x).abs
  end

  def y_dimensions()
    (@max_y - @min_y).abs
  end

  def z_dimensions()
    (@max_z - @min_z).abs
  end

  def process(infilename)
    resetVariables()
    totalVolume = 0

    @f = open(infilename, "rb")

    # Set the file type to ascii if needed
    @file_type = :ascii if(@f.gets.include? "solid")

    # Go back to beginning of the file
    @f.seek(0)

    read_header()
    @num_triangles = read_length()
    begin
      while true do
        totalVolume +=read_triangle()
      end
    rescue
      # This means it is the end of file which is a desired error here
      nil
    end

    @volume = totalVolume
  end
end
