module Api::ApiHelpers::Exceptions
  class LimitReachedError < StandardError; end
  class UnknownError < StandardError; end
end
