
module MEGAUNI
  struct News_All

    def root
      section(:Treasure_Trail)
      section recently_viewed(combo_of subscribed, viewed)
      section sorted_by published_date, name
      section view_more(:button)
    end # === def root

  end # === struct News_All
end # === module MEGAUNI
