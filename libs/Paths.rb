class Paths

  def Paths.homefolder
    Dir.home
  end

  def Paths.config_dir
    File.join(Paths.homefolder, ".encryptingcamera")
  end

end
