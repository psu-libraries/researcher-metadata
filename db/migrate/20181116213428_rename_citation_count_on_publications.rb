# frozen_string_literal: true

class RenameCitationCountOnPublications < ActiveRecord::Migration[5.2]
  def change
    rename_column :publications, :citation_count, :total_scopus_citations
  end
end
