class ApplicationController < ActionController::API
  Unauthorized = Class.new(StandardError)

  include Response
  include ExceptionHandler
end
