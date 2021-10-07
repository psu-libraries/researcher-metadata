class WOSAuthorName
  def initialize(full_name)
    @full_name = full_name
  end

  def first_name
    first_name_or_initial if first_name_or_initial && first_name_or_initial.length > 1
  end

  def middle_name
    middle_name_or_initial if middle_name_or_initial && middle_name_or_initial.length > 1
  end

  def last_name
    full_name.split(',')[0]
  end

  def first_initial
    first_name_or_initial if first_name_or_initial && first_name_or_initial.length == 1
  end

  def middle_initial
    middle_name_or_initial if middle_name_or_initial && middle_name_or_initial.length == 1
  end

  private

    attr_reader :full_name

    def first_name_or_initial
      first_and_middle[0].gsub('.', '') if first_and_middle
    end

    def middle_name_or_initial
      first_and_middle[1].gsub('.', '') if first_and_middle && first_and_middle[1]
    end

    def first_and_middle
      full_name.split(',')[1].strip.split(' ') if full_name.split(',')[1]
    end
end
