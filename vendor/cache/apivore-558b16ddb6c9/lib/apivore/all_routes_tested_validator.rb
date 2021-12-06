module Apivore
  class AllRoutesTestedValidator

    def matches?(swagger_checker)
      @errors = []
      swagger_checker.untested_mappings.each do |path, methods|
        methods.each do |method, codes|
          codes.each do |code, _|
            @errors << "#{method} #{path} is untested for response code #{code}"
          end
        end
      end

      @errors.empty?
    end

    def description
      "have tested all documented routes"
    end

    def failure_message
      @errors.join("\n")
    end
  end
end
