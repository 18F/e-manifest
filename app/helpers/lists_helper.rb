module ListsHelper
  def with_comma(l)
    l.to_sentence two_words_connector: ', ', last_word_connector: ', '
  end
end
