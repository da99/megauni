
module MEGAUNI
  struct Group

    def root
      section(:settings)
      type(:family, :friends, :work, :school, :etc)
      section(:join, :cancel, :edit_news_folder)
      section(:news)

      section(
        :high_priority, :expiring_soon, :due_dates
      )
      section(
        :activities,
        :editable_lists,
        :rate_or_vote,
        :edit_and_improve_tidywiki_note
      )

      section(:q_n_a)
      section(:shopping)
      section(:guides_and_reviews)
    end # === def root

  end # === struct Group
end # === module MEGAUNI
