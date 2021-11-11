# frozen_string_literal: true

class AuthorshipClaimService
  def initialize(user, publication, author_number)
    @user = user
    @publication = publication
    @author_number = author_number
  end

  def create
    authorship = user.claim_publication(publication, author_number)
    AdminNotificationsMailer.authorship_claim(authorship).deliver_now
  end

  private

    attr_reader :user, :publication, :author_number
end
