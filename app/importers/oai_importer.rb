class OAIImporter
  def call
    load_records

    repo_records.each do |rr|
      if rr.importable?
        ActiveRecord::Base.transaction do
          
          # - check for matching import
          # - create import if not found
          # - check whether publication has been edited
          # - check whether publication has a Pure or AI import
          # - create or update publication
          # - detect and group duplicates

          # - create or update confirmed authorships for user matches
          # - create or update unconfirmed authorships for ambiguous user matches
          # - create or update a contributor for each creator
        end
      end
    end
  end

  def creator_type
    raise NotImplementedError.new("This method should be defined in a subclass")
  end

  private

  attr_reader :repo_records

  def repo_url
    raise NotImplementedError.new("This method should be defined in a subclass")
  end

  def import_source
    raise NotImplementedError.new("This method should be defined in a subclass")
  end

  def repo
    @repo ||= Fieldhand::Repository.new(repo_url)
  end

  def load_records
    @repo_records = []
    repo.records.each do |r|
      @repo_records.push OAIRepoRecord.new(r, self)
    end
  end
end
