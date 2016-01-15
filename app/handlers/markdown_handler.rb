class MarkdownHandler
  class << self
    def call(template)
      compiled_source = erb.call(template)
      "MarkdownHandler.render(begin;#{compiled_source};end)"
    end

    def render(text)
      markdown.render(text).html_safe
    end

    private

    def markdown
      @options ||= markdown_options
      @syntaxer ||= HTMLWithSyntax.new(filter_html: true, hard_wrap: true)
      @markdown ||= Redcarpet::Markdown.new(@syntaxer, @options)
    end

    def markdown_options
      {
        fenced_code_blocks: true,
        no_intra_emphasis: true,
        autolink: true,
        lax_html_blocks: true
      }
    end

    def erb
      @erb ||= ActionView::Template.registered_template_handler(:erb)
    end
  end
end
