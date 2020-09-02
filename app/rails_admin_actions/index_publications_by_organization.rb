# To create this custom action we started out with the existing Rails Admin `index` action and
# modified it so that we could list records from a custom scope. We also had to pull in some
# of the private helper code from `RailsAdmin::MainController` to maintain the same functionality
# that we'd have with the default Rails Admin index action. 

module RailsAdmin
  module Config
    module Actions
      class IndexPublicationsByOrganization < RailsAdmin::Config::Actions::Base
        register_instance_option :collection do
          true
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :route_fragment do
          'by_organization'
        end

        register_instance_option :breadcrumb_parent do
          parent_model = bindings[:abstract_model].try(:config).try(:parent)
          if am = parent_model && RailsAdmin.config(parent_model).try(:abstract_model)
            [:index, am]
          else
            [:dashboard]
          end
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
            scope = Organization.find(params[:org_id]).all_publications.includes(:organizations).page(params[:page])
            if auth_scope = @authorization_adapter && @authorization_adapter.query(:index, model_config.abstract_model)
              scope = scope.merge(auth_scope)
            end
            @objects ||= model_config.abstract_model.all(options, scope)

            unless @model_config.list.scopes.empty?
              if params[:scope].blank?
                unless @model_config.list.scopes.first.nil?
                  @objects = @objects.send(@model_config.list.scopes.first)
                end
              elsif @model_config.list.scopes.collect(&:to_s).include?(params[:scope])
                @objects = @objects.send(params[:scope].to_sym)
              end
            end

            respond_to do |format|
              format.html do
                render :index_publications_by_organization, status: @status_code || :ok
              end

              format.json do
                output = begin
                  if params[:compact]
                    primary_key_method = @association ? @association.associated_primary_key : @model_config.abstract_model.primary_key
                    label_method = @model_config.object_label_method
                    @objects.collect { |o| {id: o.send(primary_key_method).to_s, label: o.send(label_method).to_s} }
                  else
                    @objects.to_json(@schema)
                  end
                end
                if params[:send_data]
                  send_data output, filename: "#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.json"
                else
                  render json: output, root: false
                end
              end

              format.xml do
                output = @objects.to_xml(@schema)
                if params[:send_data]
                  send_data output, filename: "#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.xml"
                else
                  render xml: output
                end
              end

              format.csv do
                header, encoding, output = CSVConverter.new(@objects, @schema).to_csv(params[:csv_options].permit!.to_h)
                if params[:send_data]
                  send_data output,
                            type: "text/csv; charset=#{encoding}; #{'header=present' if header}",
                            disposition: "attachment; filename=#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.csv"
                else
                  render plain: output
                end
              end
            end
          end
        end

        register_instance_option :link_icon do
          'icon-th-list'
        end
      end
    end
  end
end
