class HTMLWithSyntax < Redcarpet::Render::HTML
  def block_code(code, language)
    CodeRay.scan(code, language).div
  end

  def header(text, header_level)
    anchor_name = text.downcase.gsub(/\W+/, '-')
    %Q(<a name="#{anchor_name}"></a><h#{header_level}>#{text}</h#{header_level}>)
  end

  def doc_header
    '<div class="usa-width-one-whole">'
  end

  def doc_footer
    '</div>'
  end
end
