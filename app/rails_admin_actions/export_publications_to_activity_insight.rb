module RailsAdmin
  module Config
    module Actions
      class ExportPublicationsToActivityInsight < RailsAdmin::Config::Actions::Base
        register_instance_option :collection? do
          true
        end

        register_instance_option :pjax? do
          false
        end

        register_instance_option :visible? do
          false
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          proc do
            associations = model_config.list.fields.select { |f| f.try(:eager_load?) }.collect { |f| f.association.name }
            options = {}
            options = options.merge(include: associations) unless associations.blank?
            options = options.merge(get_sort_hash(model_config))
            options = options.merge(query: params[:query]) if params[:query].present?
            options = options.merge(filters: params[:f]) if params[:f].present?
            options = options.merge(bulk_ids: params[:bulk_ids]) if params[:bulk_ids]
            scope = Organization.find(params[:org_id]).all_publications.includes(:organizations)
            if auth_scope = @authorization_adapter && @authorization_adapter.query(:index, model_config.abstract_model)
              scope = scope.merge(auth_scope)
            end

            @objects ||= model_config.abstract_model.all(options, scope)
            if request.get?
              @org_name = Organization.find(params[:org_id]).name
              render :export_publications_to_activity_insight
            elsif request.post?
              object_ids = @objects.pluck(:id)
              AiPublicationExportJob.new.perform(object_ids, params["_integrate"])
              flash[:notice] = I18n.t('admin.actions.export_publications_to_activity_insight.notice')
              render :index_publications_by_organization
            end
          end
        end
      end
    end
  end
end
