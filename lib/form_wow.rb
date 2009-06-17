module FormWow
  
  @@required_symbol = '*'

  @@default_decorator = 'form_wow_row'

  @@default_form_row_class = 'row'

  mattr_accessor :required_symbol, :default_decorator, :default_form_row_class

  def self.nuke_field_with_errors
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      html_tag
    end
  end
  
end
