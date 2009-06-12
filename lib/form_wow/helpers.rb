module FormWow::Helpers

  def self.included base #:nodoc:
    # Create wow_ prefixed helpers for each std rails form method
    helpers = %w(form form_for remote_form_for form_remote_for fields_for)
    helpers.each do |helper|
      self.module_eval <<-EVAL
        def wow_#{helper} name, *args, &block
          options = args.last.is_a?(Hash) ? args.pop : {}
          options[:builder] = ::FormWow::Builder
          args.push options
          #{helper} name, *args, &block
        end
      EVAL
    end
  end

  # Builds a fully-decorated form row with content (form field),
  # hints, label, required symbol, error message, etc. 
  #
  # This method requires two things, content and a label.  Content
  # can either be the first param or be passed in a block.
  # Here are two examples of how to call this method (using HAML markup):
  # 
  #   = row(content, label, options)
  #
  #  or
  #
  #   - row(label, options) do
  #     = text_field ...
  #     = select ...
  #
  # Options:
  #
  # * required : When true, the required symbol is placed in the label.
  # * required_symbol : A string to place in the label when the field is
  #   required.  Most commonly '*', defaults to FormWow.required_symbol 
  # * error : An error message string.  This error get wrapped in a span
  #   of class error.  When this option is set the class name 'invalid' is
  #   also added to the row div.
  # * hint : A short message or tip on how to fill out the form field.
  #   This tip can indicate what data format is expected (e.g. YYYY/MM/DD),
  #   or just be a short message on what the data is used for (e.g. when
  #   checked this object will be excluded from public search results ...)
  # * class : CSS class name to add to the form row div.
  # * label_for : An optional dom id of a form element that should 
  #   recieve focus when the label is clicked.
  #   
  def form_wow_row *args, &block

    options = args.last.is_a?(Hash) ? args.pop : {}
    content = block_given? ? capture(&block) : args.shift
    label = args.shift

    ## label

    req_symbol = nil
    if options[:required]
      req_symbol = options[:required_symbol] || FormWow.required_symbol
      req_symbol = content_tag('span', req_symbol, :class => 'required_symbol')
    end
    label = label_tag(options[:label_for], [req_symbol, label])

    ## hint
  
    if hint = options[:hint]
      hint = content_tag('p', hint, :class => 'hint')
    end

    ## error message

    if error = options[:error]
      error = content_tag('span', error, :class => 'error')
    end

    ## form row div

    css = []
    css << 'invalid' if options[:error] 
    css << 'required' if options[:required] 
    css << options[:class] if options[:class] 
    css << FormWow.default_form_row_class

    parts = [label, error, hint, content].join("\n")
    row = content_tag('div', parts, :class => css.join(' '))

    # return / output the form row div

    if block_given?
      concat(row)
    else
      row
    end
  end

  # Safely appends a class name to a options hash.  The passed hash is modified.
  def append_class_name! options, class_name
    key = options.has_key?('class') ? 'class' : :class 
    unless options[key].to_s =~ /(^|\s+)#{class_name}(\s+|$)/
      options[key] = "#{options[key]} #{class_name}".strip
    end
    options
  end

end
