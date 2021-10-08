# frozen_string_literal: true

class CommitteeImporter < CSVImporter
  def row_to_object(row)
    if row[:email].present?
      existing_user = User.find_by(webaccess_id: webaccess_id(row))
      existing_etd = ETD.find_by(external_identifier: row[:submission_id])

      if existing_etd && existing_user && preferred_role?(row[:committee_role_id])

        existing_committee_membership = CommitteeMembership.find_by(
          user_id: existing_user.id,
          etd_id: existing_etd.id,
          role: role(row[:committee_role_id])
        )

        if existing_etd.updated_by_user_at.blank?
          if existing_committee_membership
            nil
          else
            CommitteeMembership.new(
              etd_id: existing_etd.id,
              user_id: existing_user.id,
              role: role(row[:committee_role_id])
            )

          end
        end
      end
    end
  end

  def bulk_import(objects)
    CommitteeMembership.import(objects)
    #   unique_etds = objects.uniq { |o| o.webaccess_id.downcase }
    #   if objects.count != unique_etds.count
    #     fatal_errors << "The file contains at least one duplicate ETD."
    #   end
  end

  private

    def webaccess_id(row)
      row[:email].to_s.downcase.split('@').first
    end

    def role(role_id)
      committee_roles[role_id]
    end

    def committee_roles
      {
        1 => 'Dissertation Advisor',
        2 => 'Committee Chair',
        3 => 'Committee Member',
        4 => 'Outside Member',
        5 => 'Special Member',
        6 => 'Thesis Advisor',
        7 => 'Committee Member'
      }
    end

    def preferred_role?(role_id)
      preferred_committee_role_ids.include? role_id
    end

    def preferred_committee_role_ids
      [1, 2, 3, 6, 7]
    end
end
