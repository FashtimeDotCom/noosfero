class Noosfero::Plugin::Macro

  attr_accessor :context

  def self.configuration
#    {:generator => ''}
  end

  def self.plugin
    name.split('::')[0...-1].join('::').constantize
  end

  def initialize(context=nil)
    self.context = context
  end

  def attributes(macro)
    macro.attributes.to_hash.
      select {|key, value| key[0..10] == 'data-macro-'}.
      inject({}){|result, a| result.merge({a[0][11..-1] => a[1]})}.
      with_indifferent_access
  end

  def convert(macro, source)
    macro_name = macro['data-macro']
    attrs = attributes(macro)

    begin
      content = parse(attrs, macro.inner_html, source)
      macro['class'] = "parsed-macro #{macro_name}"
    rescue Exception => exception
      content = _("Unsupported macro %s!") % macro_name
      macro['class'] = "failed-macro #{macro_name}"
    end

    attrs.each {|key, value| macro.remove_attribute("data-macro-#{key}")}
    content
  end

  def parse(attrs, inner_html, source)
    raise
  end

end