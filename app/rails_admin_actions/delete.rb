# frozen_string_literal: true

module RailsAdmin
  module Config
    module Actions
      class Delete < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :route_fragment do
          'delete'
        end

        register_instance_option :http_methods do
          [:get, :delete]
        end

        register_instance_option :authorization_key do
          :destroy
        end

        register_instance_option :controller do
          proc do
            if request.get? # DELETE

              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.delete? # DESTROY

              @auditing_adapter&.delete_object(@object, @abstract_model, _current_user)
              if @object.destroy
                flash[:success] = t('admin.flash.successful', name: @model_config.label, action: t('admin.actions.delete.done'))
                if @object.is_a? OpenAccessLocation
                  redirect_to show_path(model_name: :publication, id: @object.publication.id)
                elsif @object.is_a? EducationHistoryItem
                  redirect_to show_path(model_name: :user, id: @object.user.id)
                else
                  redirect_to index_path
                end
              else
                handle_save_error :delete
              end

            end
          end
        end

        register_instance_option :link_icon do
          'fa fa-times'
        end

        register_instance_option :writable? do
          !(bindings[:object] && bindings[:object].readonly?)
        end
      end
    end
  end
end
