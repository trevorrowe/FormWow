# TODO : add a sample css file
# TODO : aggregate errors from EasyForm::Builder#row and add invalid clases
# TODO   to the individual fields
# TODO : document
# TODO : release and blog
ActionView::Base.send(:include, FormWow::Helpers)

# Create a wow_ prefixed version of each of the standard form builder helpers
%w(form form_for remote_form_for form_remote_for fields_for).each do |helper|
  ActionView::Base.module_eval <<-EVAL
    def wow_#{helper} name, *args, &block
      options = args.last.is_a?(Hash) ? args.pop : {}
      options[:builder] = ::FormWow::Builder
      args.push options
      #{helper} name, *args, &block
    end
  EVAL
end
