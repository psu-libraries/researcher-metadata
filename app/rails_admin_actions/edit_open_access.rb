module RailsAdmin  
  module Config
    module Actions
      class EditOpenAccess < RailsAdmin::Config::Actions::Base
        register_instance_option :member? do
          true
        end

        register_instance_option :visible? do
          bindings[:object].is_a?(Authorship) && bindings[:object].scholarsphere_uploaded_at.present?
        end

        register_instance_option :http_methods do
          %i(get patch)
        end

        register_instance_option :controller do
          proc do
            if @object.is_a?(Authorship) && @object.scholarsphere_uploaded_at.present?
              @publication = @object.publication
              @form = OpenAccessURLForm.new(open_access_url: @publication.open_access_url)
              if request.patch?
                @form.open_access_url = params[:open_access_url_form][:open_access_url]
                if @form.valid?
                  ActiveRecord::Base.transaction do
                    @publication.update_attributes!(scholarsphere_open_access_url: params[:open_access_url_form][:open_access_url])
                    @publication.authorships.each do |a|
                      a.update_attributes!(scholarsphere_uploaded_at: nil)
                    end
                  end
                  flash[:success] = I18n.t('admin.actions.edit_open_access.success', @publication.title)
                  redirect_to rails_admin.index_path(model_name: :authorship)
                else
                  flash.now[:error] = @form.errors.full_messages.join(" ")
                  render :edit_open_access
                end
              end
            else
              redirect_to rails_admin.index_path(model_name: :authorship)
              flash[:error] = I18n.t('admin.actions.edit_open_access.error')
            end
          end
        end

        register_instance_option :link_icon do
          'icon-lock' 
        end

      end
    end
  end
end
