# A mixin that implements heuritics checks for both categories.
# If there're some conditions under which a spammable object could
# directly be classified as one of the classification categories
# the logic could be implemented using heuritic checks in your subclasses
#
# See the example in `lib/green_midget/extensions/sample.rb`
#
module GreenMidget
  module HeuristicChecks

    private

    def heuristic_checks
      CATEGORIES.each do |category|
        if respond_to?(:"pass_#{category}_heuristics?") && send(:"pass_#{category}_heuristics?")
          classify_as!(category)
          return RESPONSES[category]
        end
      end
      return false
    end
  end
end
