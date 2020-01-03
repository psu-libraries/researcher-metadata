module RailsAdmin  
  module Config
    module Actions
      class EditOpenAccess < RailsAdmin::Config::Actions::Base
        register_instance_option :member? do
          true
        end

        register_instance_option :visible? do
          bindings[:object].is_a? Authorship
        end

        register_instance_option :controller do
          proc do

          end
        end

        register_instance_option :link_icon do
          'icon-lock' 
        end

      end
    end
  end
end 