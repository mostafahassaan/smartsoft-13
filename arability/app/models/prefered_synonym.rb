#encoding: UTF-8
class PreferedSynonym < ActiveRecord::Base
  attr_accessible :project_id, :synonym_id, :keyword_id
  belongs_to :project
  belongs_to :keyword
  belongs_to :synonym
  # attr_accessible :title, :body
  class << self
  	def add_keyword_and_synonym_to_project(synonym_id, keyword_id, project_id)
  		entry = PreferedSynonym.new
  		entry.project_id = project_id
  		entry.synonym_id = synonym_id
  		entry.keyword_id = keyword_id
  		return entry.save
  	end

    def find_word_in_project(project_id, keyword_id)
      keyword = PreferedSynonym.where("project_id = ? AND keyword_id = ?", project_id, keyword_id).first
      if keyword != nil
        return true
      else
        return false
      end 
    end
  end
end