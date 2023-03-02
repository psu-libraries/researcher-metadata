class FileIO < SimpleDelegator
  def initialize(stream, filename)
    @filename = filename
    super(stream)
  end

  def path
    @filename
  end

  def rewind
    0
  end

  alias :to_path :path
end
