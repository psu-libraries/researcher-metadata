class OAICreator
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def last_name
    ln = text.split(',')[0]
    ln.strip if ln
  end

  def first_name
    fn = text.split(',')[1]
    fn.strip.split(' ').first.strip if fn
  end

  def user_match
    matching_users.one? ? matching_users.first : nil
  end

  def ambiguous_user_matches
    matching_users.many? ? matching_users : []
  end

  private

  def user_scope
    raise NotImplementedError.new("This method should be defined in a subclass")
  end

  def matching_users
    user_scope.where(first_name: first_name, last_name: last_name).distinct(:id)
  end
end
