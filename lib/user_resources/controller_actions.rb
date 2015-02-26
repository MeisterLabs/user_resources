require_relative 'controller_exception_handling'

# Classes including this mixing should implement
# * current_user - returning the user that is logged in and performs the current action.
module UserResources::Controller::Actions

  PermitParams = []
  
  private

  # The following 3 methods are the methods that can be *potentially* exposed as public, 
  # by calling `enable_resource_actions`
  
  def create
    model = model_class.new
    action = action_class.new(model, current_user)

    respond_with(action.create(params))
  end

  def update
    model = model_class.find(params[:id])
    action = action_class.new(model, current_user)

    respond_with(action.update(params))
  end

  def destroy
    model = model_class.find(params[:id])
    action = action_class.new(model, current_user)

    respond_with(action.destroy)
  end


  private

  def resource_params(source = nil)
    if source
      source.permit(*PermitParams)
    else
      params.require(user_resource_class.to_s.underscore).permit(*PermitParams)
    end
  end

  def model_class
    self.class.user_resource_class
  end
  
  def action_class
    "#{model_class}Action".constantize
  end


  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  
  module ClassMethods

    def enable_user_resource_actions(user_resource_class, methods)
      cattr_accessor :user_resource_class
      self.user_resource_class = user_resource_class

      public(:create) if methods.include?(:create)
      public(:update) if methods.include?(:update)
      public(:destroy) if methods.include?(:destroy)
    end
  end
end
