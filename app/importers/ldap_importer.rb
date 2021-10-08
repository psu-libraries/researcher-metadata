# frozen_string_literal: true

class LDAPImporter
  def call
    pbar = ProgressBar.create(title: 'Importing user data from LDAP', total: User.count) unless Rails.env.test?
    ldap.open do
      User.find_each do |u|
        filter = Net::LDAP::Filter.eq('uid', u.webaccess_id)
        entry = ldap.search(base: 'dc=psu,dc=edu', filter: filter).first

        if entry
          u.orcid_identifier = entry[:edupersonorcid].first
          u.save!
        end

        pbar.increment unless Rails.env.test?
      end
    end
    pbar.finish unless Rails.env.test?
  end

  private

    def ldap
      @ldap ||= Net::LDAP.new(host: 'dirapps.aset.psu.edu', port: 389)
    end
end
