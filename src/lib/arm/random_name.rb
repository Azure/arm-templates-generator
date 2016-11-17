
module Azure::ARM

  class RandomName < String

    # noinspection RubySuperCallWithoutSuperclassInspection
    class << self
      def sign(prefix)
        s = ''
        prefix.times { s += "#{[*?a..?z].sample}" }
        s
      end

      def number(suffix)
        s = ''
        suffix.times { s += "#{rand 1..9}" }
        s
      end

      # noinspection RubyParenthesesAfterMethodCallInspection
      def new
        super << create()
      end

      def create(prefix = 3, suffix = 8)
        '' << sign(prefix) << number(suffix)
      end
    end
  end

end