# TODO : add a text method that assumes content
class FormWow::Builder < ActionView::Helpers::FormBuilder

  attr_accessor :decorator
  
  def initialize *args
    super(*args)
    @decorating = true
    @decorator = FormWow.default_decorator
  end
    
  # Use this method to wrap multiple form fields or complex form fields
  # inside a single form row (1 label, one error message, etc).
  #
  # Any output inside the row block is captured and decorated once.
  # Example:
  #
  #   - wow_form_for @person do |form|
  #     - form.row 'Name'
  #       = form.text_field :first_name
  #       = form.text_field :middle_initial
  #       = form.text_field :last_name
  #
  # The first, middle and last name text fields are wrapped in the same row.
  def row *args, &block
  
    # TODO : aggregate any errors from wrapped fields

    # we want to support both :row_class and :class options for 
    # FormWow::Builder#row so we will nicely check and move :row_class
    # to the prefered :class option
    options = args.last.is_a?(Hash) ? args.pop : {}
    options[:class] = options.delete(:row_class) if options[:row_class]
    args.push(options)

    self.disable_decorating do
      return @template.send(@decorator, *args, &block)
    end
  end

  # Will not decorate form fields inside the passed block.
  def disable_decorating &block
    begin
      @decorating = false
      yield
    ensure
      @decorating = true
    end
  end

  # FormWow::Builder extends the standard form builder provided in Rails.
  # This allows us to extend the basic form field helpers (like text_field,
  # password_field, text_area, etc) to decorate, but still use the
  # Rails-provided logic for building the basic form element.
  #
  # FormWow::Builder provides decorated methods of the following form 
  # helpers:
  #
  # * text_field
  # * password_field
  # * file_field
  # * check_box
  # * radio_button
  # * text_area
  # * select
  #
  # If you have added methods to the basic form builder and would like those
  # to be decoratable in a FormWow fashion just use this method:
  #
  #   FormWow::Builder.upgrade_helper_method(:tinymce, 'tinymce')
  #
  # The first param is the name of the helper method, the second param
  # is the class name that should be added to the decorated form row.
  def self.upgrade_helper_method method_name, row_class, append_class_to_field

    define_method(method_name) do |field_name, *args|

      options = args.last.is_a?(Hash) ? args.pop : {}
      args.push(options)

      # collect options intended for the form row decorator

      row_options = {}
      [:required, :required_symbol, :hint].each do |opt|
        row_options[opt] = options.delete(opt)
      end

      # set the row class 
      
      row_options[:class] = "#{options.delete(:row_class)} #{row_class}".strip

      # determine the dom id of the form field so we can use it in a label
      # for attribute

      if options.has_key?(:id)
        row_options[:label_for] = options[:id]
      else
        # generate a throw-away just so we can grab rails' prefered dom id
        self.label(field_name) =~ /<label for="(.+)">.+<\/label>/
        row_options[:label_for] = $1
      end

      # determine the label text

      label = options.delete(:label) || field_name.to_s.titleize

      # look for field errors

      error = options.delete(:error)
      if error.nil? and form_object
        error = Array(form_object.errors.on(field_name)).first
      end
      row_options[:error] = error

      # build (and decorate?) the form field 

      @template.append_class_name!(options, row_class) if append_class_to_field

      field = super(field_name, *args)

      if @decorating
        @template.send(@decorator, field, label, row_options)
      else
        field
      end

    end
  end

  private

  # Returns the object being represented by this form builder.  This might
  # return a nil value if the form was not given an object.
  def form_object
    object || @template.instance_variable_get("@#{@object_name}")
  end

  [
    ['text_field',     'text',     true],
    ['password_field', 'password', true],
    ['file_field',     'file',     true],
    ['check_box',      'checkbox', true],
    ['radio_button',   'radio',    true],
    ['text_area',      'textarea', false],
    ['select',         'select',   false],
  ].each do |method_name, row_class, append_class_to_field|
    upgrade_helper_method(method_name, row_class, append_class_to_field)
  end
  
end
