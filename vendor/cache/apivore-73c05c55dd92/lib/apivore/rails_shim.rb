module Apivore
  class RailsShim
    class << self
      def action_dispatch_request_args(path, params: {}, headers: {})
        { path: path, params: params, headers: headers }
      end
    end
  end
end
