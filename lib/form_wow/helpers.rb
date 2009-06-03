module FormWow::Helpers

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
    label_text = args.shift

    ## label

    label = []
    if options[:required]
      symbol = options[:required_symbol] || FormWow.required_symbol
      label << content_tag('span', symbol, :class => 'required_symbol')
    end
    label << content_tag('span', label_text, :class => 'label')
    label = content_tag('label', label, :for => options[:label_for])

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
    css << 'row'

    row = content_tag('div', [label, hint, error, content], :class => css.join(' '))

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
