class Vote < ActiveRecord::Base
  belongs_to :synonym
  belongs_to :gamer
  # attr_accessible :title, :body
  validate :validate_gamer_exists, :validate_synonym_exists, :validate_voting_for_new_keyword
  validates :gamer_id, :uniqueness => { :scope => :synonym_id, :message => "This gamer has aleready voted for this sysnonym before"} 

   # Assigned to: Nourhan Zakria
   # This method is used to record the vote given for a certain synonym by a ceratin user
   # Parameters:
   #  gamer_id: the voter(gamer) ID
   #  synonym_id: the synonym_id that the gamer voted for
   # Returns:
   #  On success: Returns true and the instance of vote that was created and saved
   #  On failure: returns false and the instance of vote that wasn't saved
  def self.record_vote(gamer_id, synonym_id) 
          @vote = Vote.new
          @vote.synonym_id = synonym_id
          @vote.gamer_id = gamer_id
            if @vote.save
              return true, @vote  
            else
              return false, @vote
   	        end
  end

   # This method is used to retreive a list of specific size of keywords that gamer with this gamer_id didn't vote on yet
   # Parameters:
   #  gamer_id: the gamer ID 
   #  count: the size of the list to be retreived
   #  lang: integer to specify the language of keywords to be retreived if 0 then english only, if 1 then arabic only, otherwise both english and arabic 
   #        keywords can be icluded
   # Returns:
   #  On success: Returns a list of un voted keywords of the specified langauge with size = count for the gamer with this gamer_id  
   #  On failure: Returns empty list
  def self.get_unvoted_keywords(gamer_id, count, lang)
      if Gamer.find_by_id(gamer_id) != nil
        voted_synonyms = Vote.where('gamer_id = ?', gamer_id).select('synonym_id')
        voted_keywords = Synonym.where(:id => voted_synonyms).select('keyword_id')
        #un_voted_keywords = Keyword.all - Keyword.where( :id => voted_keywords)
          if lang == 0
            un_voted_keywords = Keyword.where("is_english =?",true) - Keyword.where(:id => voted_keywords)
          elsif lang ==1
            un_voted_keywords = Keyword.where("is_english=?",false) - Keyword.where(:id => voted_keywords)
          else
            un_voted_keywords = Keyword.all - Keyword.where( :id => voted_keywords) 
          end
        list_returned = un_voted_keywords.take(count)

        return list_returned

      else
        return nil
      end
  end

  # Written by: Nourhan Zakaria
  #This is a custom validation method that validates that there exists a gamer with this gamer_id 
  def validate_gamer_exists
    valid_gamer = Gamer.find_by_id(gamer_id)
    if valid_gamer == nil
      errors.add(:gamer_id,"this gamer_id soesn't exist")
    end
  end

  # Written by: Nourhan Zakaria
  #This is a custom validation method that validates that there exists a synonym with this synonym_id 
  def validate_synonym_exists
    valid_synonym = Synonym.find_by_id(synonym_id)
    if valid_synonym == nil
      errors.add(:synonym_id,"this synonym_id soesn't exist")
    end
  end

  # Written by: Nourhan Zakaria
  # This is a custom validation method that validates that synonym which the gamer is voting for doesn't belong to a keyword that 
  # this gamer voted for before
  def validate_voting_for_new_keyword
    keyword_id_of_chosen_synonym=Synonym.where("id=?",synonym_id).select('Keyword_id')
    voted_synonyms = Vote.where('gamer_id = ?', gamer_id).select('synonym_id')
    voted_keywords = Synonym.where(:id => voted_synonyms).select('keyword_id')
    check = Keyword.where(:id => keyword_id_of_chosen_synonym) - Keyword.where( :id => voted_keywords)
    if check == []
       errors.add(:keyword_id,"this user voted for this keyword before")
    end
  end

end
