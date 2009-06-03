module FormWow
  
  @@required_symbol = '*'

  @@default_decorator = 'form_wow_row'

  mattr_accessor :required_symbol, :default_decorator

  def self.nuke_field_error_proc
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      html_tag
    end
  end
  
end
