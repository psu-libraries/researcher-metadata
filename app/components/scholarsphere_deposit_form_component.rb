# frozen_string_literal: true

class ScholarsphereDepositFormComponent < ViewComponent::Base
  def initialize(deposit, permissions)
    @deposit = deposit
    @permissions = permissions
  end

  def doi_present?
    @deposit.authorship.doi.present?
  end

  def permissions_alert
    if this_version_present?
      t('simple_form.scholarsphere_deposit_flashes.sharing_rules_found', this_version: this_version_text)
    elsif other_version_preferred?
      t('simple_form.scholarsphere_deposit_flashes.other_version_preferred_html',
        this_version: this_version_text,
        other_version: other_version_text,
        url: edit_open_access_publication_url(@deposit.publication))
    else
      t('simple_form.scholarsphere_deposit_flashes.sharing_rules_not_found')
    end
  end

  def rights_field(form)
    partial = render(partial: 'rights_field', locals: { f: form,
                                                        rights_selected: rights_selected,
                                                        rights_hint: rights_hint })
    if licence_present?
      content_tag(:section, content_tag(:div, partial, class: 'alert alert-info'))
    else
      partial
    end
  end

  def embargoed_until_field(form)
    partial = render(partial: 'embargoed_until_field', locals: { f: form,
                                                                 embargo_hint: embargo_hint,
                                                                 embargo_selected: embargo_selected })
    if embargo_end_date_present?
      content_tag(:section, content_tag(:div, partial, class: 'alert alert-info'))
    else
      partial
    end
  end

  def publisher_statement_field(form)
    partial = render(partial: 'publisher_statement_field',
                     locals: { f: form,
                               set_statement_input_html: set_statement_input_html,
                               set_statement_hint: set_statement_hint })
    if set_statement_present?
      content_tag(:section, content_tag(:div, partial, class: 'alert alert-info'))
    else
      partial
    end
  end

  private

    def rights_hint
      link = link_to 'FAQ', 'https://psu.libanswers.com/faq/279046', target: '_blank', rel: 'noopener'
      if licence_present?
        t('simple_form.hints.rights.oab_permission_found')
      else
        t('simple_form.hints.rights.default_html', link: link)
      end
    end

    def rights_selected
      if licence_present?
        nil
      else
        'https://rightsstatements.org/page/InC/1.0/'
      end
    end

    def embargo_hint
      if embargo_end_date_present?
        if @permissions.embargo_end_date < Date.today
          t('simple_form.hints.embargoed_until.oab_permission_found_expired')
        else
          t('simple_form.hints.embargoed_until.oab_permission_found')
        end
      end
    end

    def embargo_selected
      if embargo_end_date_present?
        if @permissions.embargo_end_date < Date.today
          nil
        else
          @permissions.embargo_end_date
        end
      end
    end

    def set_statement_input_html
      if set_statement_present?
        { rows: 7 }
      else
        {}
      end
    end

    def set_statement_hint
      if set_statement_present?
        t('simple_form.hints.publisher_statement.oab_permission_found')
      else
        t('simple_form.hints.publisher_statement.default')
      end
    end

    def licence_present?
      @permissions.licence.present?
    end

    def embargo_end_date_present?
      @permissions.embargo_end_date.present?
    end

    def set_statement_present?
      @permissions.set_statement.present?
    end

    def this_version_present?
      @permissions.this_version.present?
    end

    def other_version_preferred?
      @permissions.other_version_preferred?
    end

    def this_version_text
      version_text(@permissions.version)
    end

    def other_version_text
      version_text((OabPermissionsService::VALID_VERSIONS - [@permissions.version]).first)
    end

    def version_text(version)
      if version == I18n.t('file_versions.accepted_version')
        I18n.t('file_versions.accepted_version_display')
      else
        I18n.t('file_versions.published_version_display')
      end
    end
end
