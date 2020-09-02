module RailsAdmin
  module Config
    module Actions
      class ExportPublicationsByOrganization < RailsAdmin::Config::Actions::Base
        register_instance_option :collection do
          true
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          proc do
            if format = params[:json] && :json || params[:csv] && :csv || params[:xml] && :xml
              request.format = format
              @schema = HashHelper.symbolize(params[:schema].slice(:except, :include, :methods, :only).permit!.to_h) if params[:schema] # to_json and to_xml expect symbols for keys AND values.

              associations = model_config.list.fields.select { |f| f.try(:eager_load?) }.collect { |f| f.association.name }
              options = {}
              options = options.merge(include: associations) unless associations.blank?
              options = options.merge(get_sort_hash(model_config))
              options = options.merge(query: params[:query]) if params[:query].present?
              options = options.merge(filters: params[:f]) if params[:f].present?
              options = options.merge(bulk_ids: params[:bulk_ids]) if params[:bulk_ids]
              scope = Organization.find(params[:org_id]).all_publications.includes(:organizations)

              @objects ||= model_config.abstract_model.all(options, scope)
              index_publications_by_organization
            else
              render :export_publications_by_organization
            end
          end
        end

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :link_icon do
          'icon-share'
        end
      end
    end
  end
end
