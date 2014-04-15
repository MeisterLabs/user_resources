class UserResources::UserAction

  def initialize(resource, user)
    @resource, @user = resource, user
  end

  def create(attrs)
    raise UserResources::Forbidden if @resource.persisted?
    
    @resource.transaction do
      attrs = before_create(attrs) || attrs
      attrs = before_save(attrs) || attrs

      @resource.attributes = attrs

      raise UserResources::Forbidden unless allowed?

      # Save the record
      raise ActiveRecord::RecordInvalid.new(@resource) unless @resource.save

      after_save(attrs)
      after_create(attrs)
    end

    @resource
  end
  
  def update(attrs)
    raise UserResources::Forbidden unless @resource.persisted?
    
    @resource.transaction do

      attrs = before_update(attrs) || attrs
      attrs = before_save(attrs) || attrs

      raise UserResources::Forbidden unless allowed?

      @resource.attributes = attrs

      raise UserResources::Forbidden unless allowed?

      # Save the record
      raise ActiveRecord::RecordInvalid.new(@resource) unless @resource.save

      after_save(attrs)
      after_update(attrs)
    end

    @resource
  end

  def destroy
    @resource.transaction do
      before_destroy
    
      raise UserResources::Forbidden unless allowed?
      
      @resource.destroy
    
      after_destroy
    end
    
    @resource
  end


  protected

  def allowed?
    raise NotImplementedError
  end


  def before_create(attrs)
  end

  def after_create(attrs)
  end

  def before_update(attrs)
  end

  def before_save(attrs)
  end

  def after_update(attrs)
  end
  
  def after_save(attrs)
  end

  def before_destroy
  end
  
  def after_destroy
  end
  
  
  # Helper method to see if an attribute has been changed by this action. By passing `to` one can
  # also check if that attribute changed to a specific value.
  def attribute_changed?(attrs, attribute, to = nil)
    before = @resource.attributes[attribute] 
    after = attrs[attribute]
    
    if attrs.key?(attribute) && before != after
      to ? after == to : true    
    else
      false
    end
  end
end
